open Js_of_ocaml
open Js_of_ocaml_lwt
open Lwt.Infix
open Js_of_ocaml_tyxml
open Tyxml_js.Html

let section_card title content =
  div
    ~a:[a_class ["card"; "mb-3"]]
    [ div
        ~a:[a_class ["card-header"]]
        [h6 ~a:[a_class ["card-title"; "mb-0"]] [txt title]]
    ; div ~a:[a_class ["card-body"]] content ]

let select_options opts current =
  List.map
    (fun o ->
      option
        ~a:([a_value o] @ if o = current then [a_selected ()] else [])
        (txt o) )
    opts

let users_loaded : bool ref = ref false

let users_loading : bool ref = ref false

let users_error : string option ref = ref None

let users_notice : string option ref = ref None

let users_list : Api.Openapi.adminUsersGetResponse2 ref = ref []

let user_row_editing_id : int option ref = ref None

let user_row_username : string ref = ref ""

let user_row_role : string ref = ref "user"

let user_row_groups : string ref = ref ""

let selected_user_ids : int list ref = ref []

let user_create_username : string ref = ref ""

let user_create_password : string ref = ref ""

let user_create_role : string ref = ref "user"

let user_action_busy : bool ref = ref false

let clear_selected_users () = selected_user_ids := []

let clear_user_notice_error () =
  users_error := None ;
  users_notice := None

let reset_user_edit_state () =
  user_row_editing_id := None ;
  user_row_username := "" ;
  user_row_role := "user" ;
  user_row_groups := ""

let reset_user_create_state () =
  user_create_username := "" ;
  user_create_password := "" ;
  user_create_role := "user"

let reset_state () =
  users_loaded := false ;
  users_loading := false ;
  clear_user_notice_error () ;
  users_list := [] ;
  reset_user_edit_state () ;
  reset_user_create_state () ;
  clear_selected_users () ;
  user_action_busy := false

let admin_role_of_string r =
  try Api.Openapi.UserRole.of_json ("\"" ^ r ^ "\"")
  with _ -> Api.Openapi.User

let admin_update_role_of_string r =
  Api.Openapi.UserRole.of_json ("\"" ^ r ^ "\"")

let string_of_user_role (role : Api.Openapi.userRole) =
  Api.Openapi.UserRole.to_json role
  |> String.lowercase_ascii |> Helpers.cleanup_json_string

let role_options =
  List.map string_of_user_role
    [Api.Openapi.User; Api.Openapi.Judge; Api.Openapi.Admin]

let user_role_badge_class = function
  | Api.Openapi.Admin -> "text-bg-danger"
  | Api.Openapi.Judge -> "text-bg-warning"
  | _ -> "text-bg-secondary"

let is_user_selected user_id = List.mem user_id !selected_user_ids

let set_user_selected user_id selected =
  if selected then (
    if not (is_user_selected user_id) then
      selected_user_ids := user_id :: !selected_user_ids )
  else
    selected_user_ids :=
      List.filter (fun id -> id <> user_id) !selected_user_ids

let selected_users_count () = List.length !selected_user_ids

let all_users_selected () =
  !users_list <> []
  && List.for_all
       (fun (user : Api.Openapi.user) -> is_user_selected user.id)
       !users_list

let set_all_users_selected selected =
  if selected then
    selected_user_ids :=
      List.map (fun (user : Api.Openapi.user) -> user.id) !users_list
  else clear_selected_users ()

let parse_groups_field groups_text =
  groups_text |> String.split_on_char ',' |> List.map String.trim
  |> List.filter (fun group -> group <> "")

let user_selection_cell (user : Api.Openapi.user) =
  td
    ~a:[a_class ["text-center"]]
    [ input
        ~a:
          ( [a_class ["form-check-input"]; a_input_type `Checkbox]
          @ [ a_onchange (fun ev ->
                  let target =
                    Js.Opt.get
                      (Dom_html.CoerceTo.input
                         (Js.Opt.get ev##.target (fun () -> assert false)) )
                      (fun () -> assert false)
                  in
                  Console.console##log
                    (Js.string
                       (Printf.sprintf "User %d selection changed: %b"
                          user.id
                          (Js.to_bool target##.checked) ) ) ;
                  set_user_selected user.id (Js.to_bool target##.checked) ;
                  Helpers.trigger_render () ;
                  false ) ]
          @ if is_user_selected user.id then [a_checked ()] else [] )
        () ]

let user_select_all_cell () =
  th
    ~a:[a_class ["text-center"]]
    [ input
        ~a:
          ( [a_class ["form-check-input"]; a_input_type `Checkbox]
          @ [ a_onchange (fun ev ->
                  let target =
                    Js.Opt.get
                      (Dom_html.CoerceTo.input
                         (Js.Opt.get ev##.target (fun () -> assert false)) )
                      (fun () -> assert false)
                  in
                  Console.console##log
                    (Js.string
                       (Printf.sprintf "Select all changed: %b"
                          (Js.to_bool target##.checked) ) ) ;
                  set_all_users_selected (Js.to_bool target##.checked) ;
                  Helpers.trigger_render () ;
                  false ) ]
          @ if all_users_selected () then [a_checked ()] else [] )
        () ]

let user_groups_cell editing (user : Api.Openapi.user) =
  td
    [ ( if editing then
          input
            ~a:
              [ a_class ["form-control"; "form-control-sm"]
              ; a_value !user_row_groups
              ; a_placeholder (I18n.t "users_groups_placeholder")
              ; a_oninput (fun ev ->
                    let target =
                      Js.Opt.get
                        (Dom_html.CoerceTo.input
                           (Js.Opt.get ev##.target (fun () -> assert false)) )
                        (fun () -> assert false)
                    in
                    user_row_groups := Js.to_string target##.value ;
                    false ) ]
            ()
        else if user.groups = [] then txt "-"
        else
          span
            ~a:[a_class ["d-inline-flex"; "flex-wrap"; "gap-1"]]
            (List.map
               (fun group ->
                 span
                   ~a:
                     [ a_class
                         [ "badge"
                         ; "rounded-pill"
                         ; "border"
                         ; "border-secondary"
                         ; "text-secondary" ] ]
                   [txt group] )
               user.groups ) ) ]

let user_id_cell (user : Api.Openapi.user) =
  td ~a:[a_class ["fw-semibold"]] [txt (string_of_int user.id)]

let user_username_cell editing (user : Api.Openapi.user) =
  td
    [ ( if editing then
          input
            ~a:
              [ a_class ["form-control"; "form-control-sm"]
              ; a_value !user_row_username
              ; a_oninput (fun ev ->
                    let target =
                      Js.Opt.get
                        (Dom_html.CoerceTo.input
                           (Js.Opt.get ev##.target (fun () -> assert false)) )
                        (fun () -> assert false)
                    in
                    user_row_username := Js.to_string target##.value ;
                    false ) ]
            ()
        else txt user.username ) ]

let load_users () : unit Lwt.t =
  users_loading := true ;
  Api.Helpers.get_admin_users ()
  >>= fun (json, code) ->
  users_loading := false ;
  if code = 200 then (
    users_list := Api.Openapi.adminUsersGetResponse2_of_yojson json ;
    users_loaded := true ;
    clear_selected_users () ;
    users_error := None ;
    Helpers.trigger_render () ;
    Lwt.return () )
  else (
    users_error :=
      Some ("Failed to load users (HTTP " ^ string_of_int code ^ ")") ;
    Helpers.trigger_render () ;
    Lwt.return () )

let create_admin_user ~username ~password ~role ?(groups = []) () =
  let req =
    Api.Openapi.UserCreateRequest.create ~username ~password
      ~role:(admin_role_of_string role)
      ~groups ()
  in
  Api.Helpers.post_admin_user
    (Api.Openapi.UserCreateRequest.to_yojson req |> Yojson.Safe.to_basic)
  >>= fun (json, code) ->
  if code = 200 || code = 201 then Lwt.return (Ok ())
  else
    let json = Api.Openapi.ErrorResponse.of_yojson json in
    Lwt.return (Error (json.error, code))

let save_new_user () : unit Lwt.t =
  let username = String.trim !user_create_username in
  let password = String.trim !user_create_password in
  if username = "" || password = "" then (
    users_error := Some (I18n.t "users_validation_required") ;
    Helpers.trigger_render () ;
    Lwt.return () )
  else (
    user_action_busy := true ;
    clear_user_notice_error () ;
    create_admin_user ~username ~password ~role:!user_create_role ()
    >>= function
    | Ok () ->
        user_action_busy := false ;
        reset_user_create_state () ;
        users_notice := Some (I18n.t "users_notice_created") ;
        load_users ()
    | Error (error, code) ->
        user_action_busy := false ;
        users_error :=
          Some
            ( "Failed to create user (HTTP " ^ string_of_int code ^ "): "
            ^ error ) ;
        Helpers.trigger_render () ;
        Lwt.return () )

let start_edit_user (user : Api.Openapi.user) =
  user_row_editing_id := Some user.id ;
  user_row_username := user.username ;
  user_row_role := string_of_user_role user.role ;
  user_row_groups := String.concat ", " user.groups ;
  users_error := None ;
  users_notice := None

let save_user_row (user : Api.Openapi.user) : unit Lwt.t =
  let username = String.trim !user_row_username in
  if username = "" then (
    users_error := Some (I18n.t "users_validation_required") ;
    Helpers.trigger_render () ;
    Lwt.return () )
  else (
    user_action_busy := true ;
    clear_user_notice_error () ;
    let groups = parse_groups_field !user_row_groups in
    let req =
      Api.Openapi.UserUpdateRequest.create ~username
        ~role:(admin_update_role_of_string !user_row_role)
        ~groups ()
    in
    Api.Helpers.put_admin_user user.id
      (Api.Openapi.UserUpdateRequest.to_yojson req |> Yojson.Safe.to_basic)
    >>= fun (_json, code) ->
    user_action_busy := false ;
    if code = 200 || code = 201 then (
      reset_user_edit_state () ;
      users_notice := Some (I18n.t "users_notice_updated") ;
      load_users () )
    else (
      users_error :=
        Some ("Failed to update user (HTTP " ^ string_of_int code ^ ")") ;
      Helpers.trigger_render () ;
      Lwt.return () ) )

(* [TODO] this has a ugly conmfirm form *)
let delete_selected_users () : unit Lwt.t =
  let selected_ids = List.rev !selected_user_ids in
  if selected_ids = [] then Lwt.return ()
  else
    let confirmation =
      I18n.interpolate
        (I18n.t "users_delete_confirm")
        [string_of_int (List.length selected_ids)]
    in
    if not (Js.to_bool (Dom_html.window##confirm (Js.string confirmation)))
    then Lwt.return ()
    else (
      user_action_busy := true ;
      users_notice := None ;
      users_error := None ;
      Helpers.trigger_render () ;
      let delete_one failed_ids user_id =
        Api.Helpers.delete_admin_user user_id
        >|= fun code ->
        if List.mem code [200; 201; 204] then failed_ids
        else user_id :: failed_ids
      in
      Lwt_list.fold_left_s delete_one [] selected_ids
      >>= fun failed_ids ->
      user_action_busy := false ;
      clear_selected_users () ;
      load_users ()
      >>= fun () ->
      if failed_ids = [] then
        users_notice := Some (I18n.t "users_notice_deleted")
      else
        users_error :=
          Some
            (I18n.interpolate
               (I18n.t "users_delete_failed")
               [string_of_int (List.length failed_ids)] ) ;
      Helpers.trigger_render () ;
      Lwt.return () )

let user_role_select current on_change =
  select
    ~a:
      [ a_class ["form-select"; "form-select-sm"]
      ; a_onchange (fun ev ->
            let target =
              Js.Opt.get
                (Dom_html.CoerceTo.select
                   (Js.Opt.get ev##.target (fun () -> assert false)) )
                (fun () -> assert false)
            in
            on_change (Js.to_string target##.value) ;
            false ) ]
    (select_options role_options current)

let user_role_cell editing (user : Api.Openapi.user) =
  td
    [ ( if editing then
          user_role_select !user_row_role (fun value ->
              user_row_role := value )
        else
          span
            ~a:[a_class ["badge"; user_role_badge_class user.role]]
            [txt (String.capitalize_ascii (string_of_user_role user.role))]
      ) ]

let user_created_at_cell (user : Api.Openapi.user) = td [txt user.created_at]

let user_last_seen_at_cell (user : Api.Openapi.user) =
  td [txt (match user.last_seen_at with Some value -> value | None -> "-")]

let user_actions_cell editing (user : Api.Openapi.user) =
  td
    ~a:[a_class ["text-end"]]
    ( if editing then
        [ div
            ~a:[a_class ["btn-group"; "btn-group-sm"]]
            [ button
                ~a:
                  ( [ a_class ["btn"; "btn-success"]
                    ; a_onclick (fun _ ->
                          ignore (save_user_row user) ;
                          false ) ]
                  @ if !user_action_busy then [a_disabled ()] else [] )
                [txt (I18n.t "users_action_save")]
            ; button
                ~a:
                  [ a_class ["btn"; "btn-outline-secondary"]
                  ; a_onclick (fun _ ->
                        reset_user_edit_state () ;
                        Helpers.trigger_render () ;
                        false ) ]
                [txt (I18n.t "users_action_cancel")] ] ]
      else
        [ button
            ~a:
              [ a_class ["btn"; "btn-outline-primary"; "btn-sm"]
              ; a_onclick (fun _ ->
                    start_edit_user user ; Helpers.trigger_render () ; false )
              ]
            [txt (I18n.t "users_action_edit")] ] )

(* ---                       --- *)
(* --- Users import from CSV --- *)
(* ---                       --- *)
type import_user_row =
  { line_number: int
  ; username: string
  ; password: string
  ; role: string
  ; groups: string list }

let read_file_text (file : File.file Js.t) : string Lwt.t =
  let waiter, wakener = Lwt.wait () in
  let promise = Js.Unsafe.meth_call file "text" [||] in
  let on_success =
    Js.wrap_callback (fun value ->
        Lwt.wakeup_later wakener (Js.to_string value) )
  in
  let on_error =
    Js.wrap_callback (fun _ ->
        Lwt.wakeup_later_exn wakener (Failure "file_read_error") )
  in
  ignore
    (Js.Unsafe.meth_call promise "then"
       [|Js.Unsafe.inject on_success; Js.Unsafe.inject on_error|] ) ;
  waiter

let split_csv_columns line =
  let len = String.length line in
  let buf = Buffer.create len in
  let emit acc =
    let column = Buffer.contents buf |> String.trim in
    Buffer.clear buf ; column :: acc
  in
  let rec parse i quoted acc =
    if i = len then List.rev (emit acc)
    else
      match line.[i] with
      | '"' ->
          if quoted && i + 1 < len && line.[i + 1] = '"' then (
            Buffer.add_char buf '"' ;
            parse (i + 2) quoted acc )
          else parse (i + 1) (not quoted) acc
      | ',' when not quoted -> parse (i + 1) quoted (emit acc)
      | c ->
          Buffer.add_char buf c ;
          parse (i + 1) quoted acc
  in
  if len = 0 then [] else parse 0 false []

let parse_import_users_csv (csv_text : string) :
    import_user_row list * string list =
  let lines =
    csv_text |> String.split_on_char '\n' |> List.map String.trim
    |> List.filter (fun line -> line <> "")
  in
  match lines with
  | [] -> ([], [I18n.t "users_import_empty_file"])
  | header :: data_lines ->
      let header_cols =
        split_csv_columns header |> List.map String.lowercase_ascii
      in
      let has_groups_header =
        header_cols = ["username"; "password"; "role"; "groups"]
      in
      if not has_groups_header then
        ([], [I18n.t "users_import_invalid_header"])
      else
        let rec loop line_no rows errors = function
          | [] -> (List.rev rows, List.rev errors)
          | line :: rest -> (
              let cols = split_csv_columns line in
              Console.console##log
                (Js.string
                   (Printf.sprintf "Parsing line %d: %s" line_no line) ) ;
              let next_line = line_no + 1 in
              match cols with
              | [username; password; role; groups] ->
                  let username = String.trim username in
                  let password = String.trim password in
                  let groups_lst =
                    String.split_on_char ',' (String.trim groups)
                  in
                  if username = "" || password = "" then
                    loop next_line rows
                      [ I18n.t "users_import_invalid_row"
                        ^ " " ^ string_of_int line_no ]
                      rest
                  else
                    loop next_line
                      ( { line_number= line_no
                        ; username
                        ; password
                        ; role
                        ; groups= groups_lst }
                      :: rows )
                      errors rest
              | _ ->
                  loop next_line rows
                    [ I18n.t "users_import_invalid_row"
                      ^ " " ^ string_of_int line_no ]
                    rest )
        in
        loop 2 [] [] data_lines

let create_user_from_import_row row =
  create_admin_user ~username:row.username ~password:row.password
    ~role:row.role ~groups:row.groups ()
  >>= function
  | Ok () -> Lwt.return (true, "")
  | Error (error, code) ->
      let error_message =
        Printf.sprintf "Line %d: %s (HTTP %d)" row.line_number error code
      in
      Lwt.return (false, error_message)

let take_first n items =
  let rec loop i acc = function
    | [] -> List.rev acc
    | _ when i <= 0 -> List.rev acc
    | x :: xs -> loop (i - 1) (x :: acc) xs
  in
  loop n [] items

let import_users_from_file (file : File.file Js.t) : unit Lwt.t =
  user_action_busy := true ;
  users_error := None ;
  users_notice := Some (I18n.t "users_import_in_progress") ;
  Helpers.trigger_render () ;
  read_file_text file
  >>= fun content ->
  let rows, parse_errors = parse_import_users_csv content in
  if rows = [] then (
    user_action_busy := false ;
    users_error := Some (String.concat "; " parse_errors) ;
    users_notice := None ;
    Helpers.trigger_render () ;
    Lwt.return () )
  else
    Lwt_list.fold_left_s
      (fun (ok_count, fail_messages) row ->
        create_user_from_import_row row
        >>= fun (ok, error) ->
        if ok then Lwt.return (ok_count + 1, fail_messages)
        else Lwt.return (ok_count, error :: fail_messages) )
      (0, []) rows
    >>= fun (ok_count, api_fail_messages_rev) ->
    let api_fail_messages = List.rev api_fail_messages_rev in
    Console.console##log
      (Js.string
         (Printf.sprintf "Users import completed: %d OK, %d failed" ok_count
            (List.length api_fail_messages) ) ) ;
    let all_errors = parse_errors @ api_fail_messages in
    let error_count = List.length all_errors in
    user_action_busy := false ;
    if ok_count > 0 then
      users_notice :=
        Some
          (I18n.interpolate
             (I18n.t "users_import_summary")
             [string_of_int ok_count; string_of_int error_count] )
    else users_notice := None ;
    ( if all_errors = [] then users_error := None
      else
        let shown = take_first 5 all_errors in
        let suffix = if List.length all_errors > 5 then " ..." else "" in
        users_error := Some (String.concat "; " shown ^ suffix) ) ;
    Helpers.trigger_render () ;
    if ok_count > 0 then load_users () else Lwt.return ()

(** Handle changes to the users import file input *)
let import_users_file_input_change (ev : Dom_html.event Js.t) : bool =
  let target =
    Js.Opt.get
      (Dom_html.CoerceTo.input
         (Js.Opt.get ev##.target (fun () -> assert false)) )
      (fun () -> assert false)
  in
  let first_file =
    let files = target##.files in
    if files##.length = 0 then None else Js.Opt.to_option (files##item 0)
  in
  ( match first_file with
  | None -> ()
  | Some file ->
      ignore
        (Lwt.catch
           (fun () -> import_users_from_file file)
           (fun _exn ->
             user_action_busy := false ;
             users_notice := None ;
             users_error := Some (I18n.t "users_import_read_failed") ;
             Helpers.trigger_render () ;
             Lwt.return () ) ) ) ;
  target##.value := Js.string "" ;
  false

(** Import users from a file *)
let import_users () : unit Lwt.t =
  if !user_action_busy then Lwt.return ()
  else
    let input_opt : Dom_html.inputElement Js.t option =
      Option.bind
        (Js.Opt.to_option
           (Dom_html.document##getElementById
              (Js.string "users-import-file") ) )
        (fun elt -> Js.Opt.to_option (Dom_html.CoerceTo.input elt))
    in
    match input_opt with
    | None ->
        users_error := Some (I18n.t "users_import_input_missing") ;
        Helpers.trigger_render () ;
        Lwt.return ()
    | Some input_el ->
        ignore (Js.Unsafe.meth_call input_el "click" [||]) ;
        Lwt.return ()

(* ---                           --- *)
(* --- End Users Import from CSV --- *)
(* ---                           --- *)

let render_users_tab () =
  let _ =
    if (not !users_loaded) && not !users_loading then ignore (load_users ())
  in
  let create_form () =
    div
      ~a:[a_class ["row"; "g-3"; "align-items-end"]]
      [ div
          ~a:[a_class ["col-12"; "col-lg-4"]]
          [ label
              ~a:[a_class ["form-label"]]
              [txt (I18n.t "users_col_username")]
          ; input
              ~a:
                [ a_class ["form-control"]
                ; a_value !user_create_username
                ; a_placeholder (I18n.t "users_create_username_placeholder")
                ; a_oninput (fun ev ->
                      let target =
                        Js.Opt.get
                          (Dom_html.CoerceTo.input
                             (Js.Opt.get ev##.target (fun () -> assert false)) )
                          (fun () -> assert false)
                      in
                      user_create_username := Js.to_string target##.value ;
                      false ) ]
              () ]
      ; div
          ~a:[a_class ["col-12"; "col-lg-4"]]
          [ label
              ~a:[a_class ["form-label"]]
              [txt (I18n.t "users_create_password")]
          ; input
              ~a:
                [ a_input_type `Password
                ; a_class ["form-control"]
                ; a_value !user_create_password
                ; a_placeholder (I18n.t "users_create_password_placeholder")
                ; a_oninput (fun ev ->
                      let target =
                        Js.Opt.get
                          (Dom_html.CoerceTo.input
                             (Js.Opt.get ev##.target (fun () -> assert false)) )
                          (fun () -> assert false)
                      in
                      user_create_password := Js.to_string target##.value ;
                      false ) ]
              () ]
      ; div
          ~a:[a_class ["col-12"; "col-lg-2"]]
          [ label ~a:[a_class ["form-label"]] [txt (I18n.t "users_col_role")]
          ; user_role_select !user_create_role (fun value ->
                user_create_role := value ) ]
      ; div
          ~a:[a_class ["col-12"; "col-lg-2"]]
          [ button
              ~a:
                ( [ a_class ["btn"; "btn-primary"; "w-100"]
                  ; a_onclick (fun _ ->
                        ignore (save_new_user ()) ;
                        false ) ]
                @ if !user_action_busy then [a_disabled ()] else [] )
              [txt (I18n.t "users_create_submit")] ] ]
  in
  let toolbar_actions () =
    let selected_count = selected_users_count () in
    div
      ~a:[a_class ["d-flex"; "flex-wrap"; "gap-2"; "align-items-center"]]
      [ button
          ~a:
            ( [ a_class ["btn"; "btn-outline-secondary"; "btn-sm"]
              ; a_onclick (fun _ ->
                    ignore (import_users ()) ;
                    false ) ]
            @ if !user_action_busy then [a_disabled ()] else [] )
          [txt (I18n.t "users_import_btn")]
      ; button
          ~a:
            ( [ a_class ["btn"; "btn-outline-secondary"; "btn-sm"]
              ; a_onclick (fun _ ->
                    ignore
                      ( clear_user_notice_error () ;
                        load_users () ) ;
                    false ) ]
            @ if !user_action_busy then [a_disabled ()] else [] )
          [txt (I18n.t "users_refresh_btn")]
      ; button
          ~a:
            ( [ a_class ["btn"; "btn-outline-danger"; "btn-sm"]
              ; a_onclick (fun _ ->
                    ignore (delete_selected_users ()) ;
                    false ) ]
            @
            if selected_count = 0 || !user_action_busy then [a_disabled ()]
            else [] )
          [ txt
              (I18n.interpolate
                 (I18n.t "users_delete_selected_btn")
                 [string_of_int selected_count] ) ] ]
  in
  let user_table_row (user : Api.Openapi.user) =
    let editing = !user_row_editing_id = Some user.id in
    tr
      [ user_selection_cell user
      ; user_id_cell user
      ; user_username_cell editing user
      ; user_role_cell editing user
      ; user_groups_cell editing user
      ; user_created_at_cell user
      ; user_last_seen_at_cell user
      ; user_actions_cell editing user ]
  in
  let body () =
    if !users_loading && !users_list = [] then
      div [txt (I18n.t "users_loading")]
    else
      div
        [ div
            ~a:
              [ a_class
                  [ "d-flex"
                  ; "justify-content-between"
                  ; "align-items-center"
                  ; "mb-3" ] ]
            [ div
                [ h6 ~a:[a_class ["mb-1"]] [txt (I18n.t "users_manage_title")]
                ; p
                    ~a:[a_class ["text-body-secondary"; "mb-0"]]
                    [txt (I18n.t "users_manage_subtitle")] ]
            ; input
                ~a:
                  [ a_id "users-import-file"
                  ; a_class ["d-none"]
                  ; a_input_type `File
                  ; a_accept [".csv,text/csv"]
                  ; a_onchange import_users_file_input_change ]
                ()
            ; toolbar_actions () ]
        ; section_card (I18n.t "users_create_title") [create_form ()]
        ; ( match !users_error with
          | None -> div []
          | Some message ->
              div ~a:[a_class ["alert"; "alert-danger"; "mt-3"]] [txt message]
          )
        ; ( match !users_notice with
          | None -> div []
          | Some message ->
              div ~a:[a_class ["alert"; "alert-info"; "mt-3"]] [txt message]
          )
        ; div
            ~a:[a_class ["table-responsive"; "mt-3"]]
            [ table
                ~a:
                  [ a_class
                      [ "table"
                      ; "table-striped"
                      ; "table-hover"
                      ; "align-middle"
                      ; "mb-0" ] ]
                ( tr
                    ~a:[a_class ["table-light"]]
                    [ user_select_all_cell ()
                    ; th [txt (I18n.t "users_col_id")]
                    ; th [txt (I18n.t "users_col_username")]
                    ; th [txt (I18n.t "users_col_role")]
                    ; th [txt (I18n.t "users_col_groups")]
                    ; th [txt (I18n.t "users_col_created_at")]
                    ; th [txt (I18n.t "users_col_last_seen_at")]
                    ; th
                        ~a:[a_class ["text-end"]]
                        [txt (I18n.t "users_col_actions")] ]
                :: List.map user_table_row !users_list ) ] ]
  in
  section_card (I18n.t "settings_tab_users") [body ()]
