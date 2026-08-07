open Js_of_ocaml
open Js_of_ocaml_tyxml
open Tyxml_js.Html
open Lwt.Infix

(* --- Types --- *)

type difficulty = Easy | Medium | Hard

let difficulty_label = function
  | Easy -> "Easy"
  | Medium -> "Medium"
  | Hard -> "Hard"

let difficulty_color = function
  | Easy -> "success"
  | Medium -> "warning"
  | Hard -> "danger"

type problem_state =
  { problems: Api.Openapi.problem list
  ; testcases: (int, Api.Openapi.testCase list) Hashtbl.t
  ; contest_id: int option
  ; search: string
  ; selected_code: string option
  ; difficulty_filter: difficulty option }

type edit_mode =
  | Create of Api.Openapi.problem
  | Edit of Api.Openapi.problem
  | None_

(* --- State --- *)

let state : problem_state ref =
  ref
    { problems= []
    ; testcases= Hashtbl.create 16
    ; contest_id= None
    ; search= ""
    ; selected_code= None
    ; difficulty_filter= None }

let edit_mode : edit_mode ref = ref None_

let loading : bool ref = ref false

let error_msg : string option ref = ref None

let last_loaded = ref None

let contest_select =
  select ~a:[a_id "problem-select"; a_class ["form-select"; "w-auto"]] []

(* --- Helpers --- *)

let section_card title content =
  Tyxml_js.Html.div
    ~a:[a_class ["card"; "mb-3"]]
    [ div
        ~a:[a_class ["card-header"]]
        [h6 ~a:[a_class ["card-title"; "mb-0"]] [txt title]]
    ; div ~a:[a_class ["card-body"]] content ]

let toggle_switch ~checked ~label_text ~on_change () =
  let attrs =
    [ a_input_type `Checkbox
    ; a_class ["form-check-input"]
    ; a_id ("toggle-" ^ label_text)
    ; a_onchange (fun ev ->
          let target =
            Js.Opt.get
              (Dom_html.CoerceTo.input
                 (Js.Opt.get ev##.target (fun () -> assert false)) )
              (fun () -> assert false)
          in
          on_change (Js.to_bool target##.checked) ;
          false ) ]
    @ if checked then [a_checked ()] else []
  in
  div
    ~a:[a_class ["d-flex"; "justify-content-between"; "align-items-center"]]
    [ label [txt label_text]
    ; div
        ~a:[a_class ["form-check"; "form-switch"]]
        [ input ~a:attrs ()
        ; label
            ~a:
              [ a_class ["form-check-label"]
              ; a_label_for ("toggle-" ^ label_text) ]
            [] ] ]

(* --- Load data for contest --- *)

let load_problems contest_id =
  loading := true ;
  error_msg := None ;
  (*Helpers.trigger_render () ;*)
  Api.Helpers.get_problems contest_id
  >>= fun (resp, status) ->
  if status <> 200 then (
    error_msg :=
      Some (Printf.sprintf "Failed to load problems: HTTP %d" status) ;
    loading := false ;
    Helpers.trigger_render () ;
    Lwt.return_unit )
  else begin
    let problems =
      Api.Openapi.ContestsContestsidProblemsGetResponse2.of_yojson resp
    in
    state := {!state with problems; contest_id= Some contest_id} ;
    Hashtbl.clear !state.testcases ;
    loading := false ;
    error_msg := None ;
    Helpers.trigger_render () ;
    Lwt.return_unit
  end

let load_testcases contest_id problem_id =
  match Hashtbl.find_opt !state.testcases problem_id with
  | Some _ -> Lwt.return_unit (* already loaded *)
  | None ->
      Api.Helpers.get_testcases contest_id problem_id
      >>= fun (resp, status) ->
      if status <> 200 then Lwt.return_unit
      else
        let cases =
          Api.Openapi.ProblemsIdTestcasesGetResponse2.of_yojson resp
        in
        Hashtbl.add !state.testcases problem_id cases ;
        Helpers.trigger_render () ;
        Lwt.return_unit

(* --- Format helpers --- *)

let format_time_ms ms =
  if ms < 1000 then Printf.sprintf "%dms" ms
  else Printf.sprintf "%.1fs" (float_of_int ms /. 1000.)

let format_memory_mb mb = Printf.sprintf "%dMB" mb

(* --- Contest selector --- *)

let current_contest_select = ref None

let contest_options (contests : Api.Openapi.contest list)
    (selected_id : int option) =
  (* clear select before filling *)
  let select = Tyxml_js.To_dom.of_select contest_select in
  select##.length := 0 ;
  List.iter
    (fun (c : Api.Openapi.contest) ->
      let opt =
        option
          ~a:
            ( [a_value (string_of_int c.id)]
            @
            match selected_id with
            | Some sid when sid = c.id -> [a_selected ()]
            | _ -> [] )
          (txt c.title)
      in
      Dom.appendChild
        (Tyxml_js.To_dom.of_select contest_select)
        (Tyxml_js.To_dom.of_option opt) )
    contests ;
  (* add a_onchange to select *)
  select##.onchange :=
    Dom_html.handler (fun ev ->
        let select =
          Js.Opt.get
            (Dom_html.CoerceTo.select (Dom_html.eventTarget ev))
            (fun () -> assert false)
        in
        let selected_index = Js.to_string select##.value in
        (* print selected_index *)
        Console.console##log
          (Js.string
             (Printf.sprintf "Selected contest index: %s" selected_index) ) ;
        current_contest_select := Some (int_of_string selected_index) ;
        Helpers.trigger_render () ;
        Js._false )

(* --- Add / Edit Modal --- *)

let make_problem_modal () =
  match !edit_mode with
  | None_ -> div []
  | mode ->
      let is_create = match mode with Create _ -> true | _ -> false in
      let title = if is_create then "Add Problem" else "Edit Problem" in
      let ( code
          , title_t
          , time_limit_ms
          , memory_limit_mb
          , description
          , input_spec
          , output_spec ) =
        match mode with
        | Create p | Edit p ->
            ( p.code
            , p.title
            , p.time_limit_ms
            , p.memory_limit_mb
            , p.description
            , p.input_spec
            , p.output_spec )
        | None_ -> ("", "", 0, 0, "", "", "")
      in
      div
        ~a:[a_id "problem-modal"]
        [ (* Backdrop *)
          div ~a:[a_class ["modal-backdrop"; "fade"; "show"]] []
        ; (* Modal dialog *)
          div
            ~a:
              [ a_class ["modal"; "fade"; "show"]
              ; a_style "display:block; z-index:1050;" ]
            [ div
                ~a:[a_class ["modal-dialog"; "modal-lg"]]
                [ div
                    ~a:[a_class ["modal-content"]]
                    [ (* Header *)
                      div
                        ~a:[a_class ["modal-header"]]
                        [ h5 ~a:[a_class ["modal-title"]] [txt title]
                        ; button
                            ~a:
                              [ a_class ["btn-close"]
                              ; a_onclick (fun _ ->
                                    edit_mode := None_ ;
                                    Helpers.trigger_render () ;
                                    false ) ]
                            [] ]
                    ; (* Body *)
                      div
                        ~a:[a_class ["modal-body"]]
                        [ div
                            ~a:[a_class ["row"; "g-3"]]
                            [ (* Code + Title row *)
                              div
                                ~a:[a_class ["col-md-4"]]
                                [ label
                                    ~a:[a_class ["form-label"]]
                                    [txt "Code *"]
                                ; input
                                    ~a:
                                      [ a_class ["form-control"]
                                      ; a_placeholder "A01"
                                      ; a_value code ]
                                    () ]
                            ; div
                                ~a:[a_class ["col-md-8"]]
                                [ label
                                    ~a:[a_class ["form-label"]]
                                    [txt "Title *"]
                                ; input
                                    ~a:
                                      [ a_class ["form-control"]
                                      ; a_placeholder "Add Two Numbers"
                                      ; a_value title_t ]
                                    () ]
                            ; (* Limits row *)
                              div
                                ~a:[a_class ["col-md-6"]]
                                [ label
                                    ~a:[a_class ["form-label"]]
                                    [txt "Time Limit (ms)"]
                                ; input
                                    ~a:
                                      [ a_class ["form-control"]
                                      ; a_input_type `Number
                                      ; a_value (string_of_int time_limit_ms)
                                      ; a_input_min (`Number 10) ]
                                    () ]
                            ; div
                                ~a:[a_class ["col-md-6"]]
                                [ label
                                    ~a:[a_class ["form-label"]]
                                    [txt "Memory Limit (MB)"]
                                ; input
                                    ~a:
                                      [ a_class ["form-control"]
                                      ; a_input_type `Number
                                      ; a_value
                                          (string_of_int memory_limit_mb)
                                      ; a_input_min (`Number 16) ]
                                    () ]
                            ; (* Description *)
                              div
                                ~a:[a_class ["col-12"]]
                                [ label
                                    ~a:[a_class ["form-label"]]
                                    [txt "Description"]
                                ; textarea
                                    ~a:
                                      [ a_class ["form-control"]
                                      ; a_rows 4
                                      ; a_placeholder
                                          "Problem description..."
                                        (*; a_value description*) ]
                                    (txt description) ]
                            ; (* Input spec *)
                              div
                                ~a:[a_class ["col-12"]]
                                [ label
                                    ~a:[a_class ["form-label"]]
                                    [txt "Input Specification"]
                                ; textarea
                                    ~a:
                                      [ a_class ["form-control"]
                                      ; a_rows 3
                                      ; a_placeholder
                                          "Describe the input format..."
                                        (*; a_value input_spec *) ]
                                    (txt input_spec) ]
                            ; (* Output spec *)
                              div
                                ~a:[a_class ["col-12"]]
                                [ label
                                    ~a:[a_class ["form-label"]]
                                    [txt "Output Specification"]
                                ; textarea
                                    ~a:
                                      [ a_class ["form-control"]
                                      ; a_rows 3
                                      ; a_placeholder
                                          "Describe the expected output..."
                                        (*; a_value output_spec *) ]
                                    (txt output_spec) ] ]
                        ; (* Footer *)
                          div
                            ~a:[a_class ["modal-footer"]]
                            [ button
                                ~a:[a_class ["btn"; "btn-secondary"]]
                                [txt "Cancel"]
                            ; button
                                ~a:[a_class ["btn"; "btn-primary"]]
                                [txt (if is_create then "Create" else "Save")]
                            ] ] ] ] ] ]

(* --- Problem card row --- *)

let problem_card (problem : Api.Openapi.problem) =
  let is_selected =
    match !state.selected_code with
    | Some c -> c = problem.code
    | None -> false
  in
  let cases =
    try
      Some
        (Hashtbl.find !state.testcases (Option.value ~default:0 problem.id))
    with Not_found -> None
  in
  let a_class_list =
    ["card"; "mb-2"; "border"; "border-secondary-subtle"; "problem-card"]
    @ if is_selected then ["shadow-sm"] else []
  in
  div
    ~a:[a_class a_class_list]
    [ (* Card header — always visible *)
      div
        ~a:
          [ a_class
              [ "card-header"
              ; "p-2"
              ; "d-flex"
              ; "align-items-center"
              ; "justify-content-between"
              ; "bg-light" ] ]
        [ div
            [ kbd ~a:[a_class ["me-2"]] [txt problem.code]
            ; span ~a:[a_class ["fw-bold"]] [txt problem.title] ]
        ; div
            ~a:[a_class ["d-flex"; "align-items-center"; "gap-1"; "ms-auto"]]
            [ (* Difficulty badge *)
              ( match !state.difficulty_filter with
              | Some _ -> div []
              | None -> div [] )
              (* placeholder for difficulty badge when field exists *)
            ; button
                ~a:
                  [ a_class ["btn"; "btn-sm"; "btn-outline-primary"]
                  ; a_onclick (fun _ ->
                        let () =
                          state :=
                            { !state with
                              selected_code=
                                ( if is_selected then None
                                  else Some problem.code ) }
                        in
                        match !state.contest_id with
                        | Some _cid ->
                            Lwt.async (fun () ->
                                (* [TODO] *)
                                (*load_testcases cid (Option.value ~default:0
                                  problem.id) >>= fun () ->*)
                                Helpers.trigger_render () ; Lwt.return () ) ;
                            false
                        | None -> false ) ]
                [ Components.Icons.list_ul_icon ~a:["me-2"] ()
                ; txt
                    ( match cases with
                    | Some _ as c ->
                        Printf.sprintf "%s (%d)"
                          (I18n.t "problems_testcases_title")
                          (List.length (Option.get c))
                    | None ->
                        Printf.sprintf "%s (0)"
                          (I18n.t "problems_testcases_title") ) ] ]
        ; button
            ~a:
              [ a_class ["btn"; "btn-sm"; "btn-outline-secondary"]
              ; a_onclick (fun _ ->
                    edit_mode := Edit problem ;
                    make_problem_modal () |> Helpers.add_element_to_app ;
                    false ) ]
            [Components.Icons.pencil_icon ()]
        ; button
            ~a:
              [ a_class ["btn"; "btn-sm"; "btn-outline-danger"]
              ; a_onclick (fun _ ->
                    Console.console##log
                      (Js.string
                         (Printf.sprintf "Delete problem code: %s"
                            problem.code ) ) ;
                    let _ =
                      match !state.contest_id with
                      | Some _cid ->
                          Components.Modal_view.make "confirm-delete-problem"
                            problem.code
                            [ p
                                [ txt
                                    (Printf.sprintf
                                       "Are you sure you want to delete  \
                                        \"%s\" problem?"
                                       problem.title ) ] ]
                            (fun () ->
                              Lwt.async (fun () ->
                                  Api.Helpers.delete_problem
                                    (Option.value ~default:0 problem.id)
                                  >>= fun status ->
                                  if status = 204 then (
                                    Settings_problems_import.RerenderFlag
                                    .set_rerender () ;
                                    Helpers.trigger_render () ;
                                    Lwt.return_unit )
                                  else Lwt.return_unit ) ;
                              false )
                            ()
                          |> Helpers.add_element_to_app
                      | None -> ()
                    in
                    false ) ]
            [Components.Icons.trash_icon ()] ]
    ; (* Card body — expandable *)
      ( if is_selected then
          div
            ~a:[a_class ["card-body"; "p-3"; "border-top"]]
            [ (* Problem metadata *)
              div
                ~a:[a_class ["row"; "g-2"; "mb-3"]]
                [ div
                    ~a:[a_class ["col-md-6"]]
                    [ label
                        ~a:[a_class ["form-label"; "fw-bold"]]
                        [txt (I18n.t "problem_time_limit")]
                    ; p
                        ~a:[a_class ["form-control-static"]]
                        [txt (format_time_ms problem.time_limit_ms)] ]
                ; div
                    ~a:[a_class ["col-md-6"]]
                    [ label
                        ~a:[a_class ["form-label"; "fw-bold"]]
                        [txt (I18n.t "problem_memory_limit")]
                    ; p
                        ~a:[a_class ["form-control-static"]]
                        [txt (format_memory_mb problem.memory_limit_mb)] ] ]
            ; (* Description *)
              div
                ~a:[a_class ["mb-3"]]
                [ label
                    ~a:[a_class ["form-label"; "fw-bold"]]
                    [txt (I18n.t "problem_description")]
                ; pre
                    ~a:
                      [ a_class
                          [ "bg-light"
                          ; "p-3"
                          ; "rounded"
                          ; "font-monospace"
                          ; "border" ] ]
                    [txt problem.description] ]
            ; (* Test cases *)
              div
                [ label
                    ~a:[a_class ["form-label"; "fw-bold"]]
                    [txt "Test Cases"]
                ; ( match cases with
                  | Some tcases ->
                      let test_case_rows =
                        List.mapi
                          (fun idx (tc : Api.Openapi.testCase) ->
                            div
                              ~a:
                                [a_class ["mb-3"; "border"; "rounded"; "p-3"]]
                              [ div
                                  ~a:
                                    [ a_class
                                        [ "d-flex"
                                        ; "align-items-center"
                                        ; "justify-content-between"
                                        ; "mb-2" ] ]
                                  [ span
                                      [ kbd
                                          [ txt
                                              (Printf.sprintf "Test %d"
                                                 (idx + 1) ) ]
                                      ; ( if tc.is_sample then
                                            span
                                              ~a:
                                                [ a_class
                                                    [ "badge"
                                                    ; "bg-info"
                                                    ; "ms-2" ] ]
                                              [txt "Sample"]
                                          else span [] ) ] ]
                              ; button
                                  ~a:
                                    [ a_class
                                        [ "btn"
                                        ; "btn-sm"
                                        ; "btn-outline-danger" ] ]
                                  [Components.Icons.trash_icon ()]
                              ; label
                                  ~a:[a_class ["form-label"]]
                                  [txt "Input"]
                              ; pre
                                  ~a:
                                    [ a_class
                                        [ "bg-light"
                                        ; "p-2"
                                        ; "rounded"
                                        ; "font-monospace" ] ]
                                  [txt tc.input]
                              ; label
                                  ~a:[a_class ["form-label"; "mt-2"]]
                                  [txt "Output"]
                              ; pre
                                  ~a:
                                    [ a_class
                                        [ "bg-light"
                                        ; "p-2"
                                        ; "rounded"
                                        ; "font-monospace" ] ]
                                  [txt tc.output] ] )
                          tcases
                      in
                      div
                        [ div
                            ~a:[a_class ["row"]]
                            (List.mapi
                               (fun i row ->
                                 div
                                   ~a:
                                     [ a_class
                                         [ ( if i mod 2 = 0 then "col-md-6"
                                             else "" ) ] ]
                                   [row] )
                               test_case_rows ) ]
                  | None -> p ~a:[a_class ["text-muted"]] [txt "Loading..."]
                  ) ] ]
        else div [] ) ]

(* --- Main render --- *)

let render_problems_tab () =
  let cid =
    match !current_contest_select with
    | Some id -> id
    | None -> Helpers.get_current_contest_id ()
  in
  Lwt.async (fun () ->
      Api.Helpers.get_contests ()
      >>= fun (contests, status) ->
      if status <> 200 then (
        Console.console##log
          (Js.string (Printf.sprintf "Failed to fetch contests: %d" status)) ;
        Lwt.return_unit )
      else
        let _ =
          contest_options
            (Api.Openapi.ContestsGetResponse2.of_yojson contests)
            (Some cid)
        in
        Lwt.return_unit ) ;
  if
    !last_loaded <> Some cid
    || Settings_problems_import.RerenderFlag.need_rerender ()
  then begin
    Settings_problems_import.RerenderFlag.unset_rerender () ;
    last_loaded := Some cid ;
    Lwt.async (fun () -> load_problems cid)
  end ;
  (* Problem list area *)
  let problem_list () =
    let filtered_problems =
      List.filter
        (fun (p : Api.Openapi.problem) ->
          let match_search =
            match !state.search with
            | "" -> true
            | s ->
                Astring.String.is_infix
                  ~affix:(String.lowercase_ascii s)
                  (String.lowercase_ascii p.code)
                || Astring.String.is_infix
                     ~affix:(String.lowercase_ascii s)
                     (String.lowercase_ascii p.title)
          in
          let match_difficulty =
            match !state.difficulty_filter with
            | None -> true
            | _ -> true (* TODO: filter by difficulty field *)
          in
          match_search && match_difficulty )
        !state.problems
    in
    div
      ~a:[a_class ["d-flex"; "flex-column"]]
      ( if List.length filtered_problems = 0 then
          [ div
              ~a:[a_class ["text-center"; "py-5"; "text-muted"]]
              [Components.Icons.inbox_icon (); p [txt "No problems found"]]
          ]
        else List.map problem_card filtered_problems )
  in
  (* Search bar *)
  let search_bar () =
    div
      ~a:[a_class ["d-flex"; "gap-2"; "mb-3"]]
      [ div
          ~a:[a_class ["position-relative"; "flex-grow-1"]]
          [ input
              ~a:
                [ a_class ["form-control"; "ps-5"]
                ; a_placeholder (I18n.t "problems_search_placeholder")
                ; a_input_type `Text ]
              ()
          ; span
              ~a:
                [ a_class
                    [ "position-absolute"
                    ; "top-50"
                    ; "translate-middle-y"
                    ; "ms-3"
                    ; "text-muted" ] ]
              [Components.Icons.search_icon ()] ]
      ; button
          ~a:
            [ a_class ["btn"; "btn-primary"]
            ; a_onclick (fun _ ->
                  edit_mode :=
                    Create
                      { id= None
                      ; code= ""
                      ; title= ""
                      ; time_limit_ms= 1000
                      ; memory_limit_mb= 256
                      ; description= ""
                      ; input_spec= ""
                      ; output_spec= "" } ;
                  Helpers.trigger_render () ;
                  false ) ]
          [ Components.Icons.plus_lg_icon ~a:["me-2"] ()
          ; txt (I18n.t "problems_add_btn") ] ]
  in
  (* Main content *)
  section_card (I18n.t "problems_title")
    [ div
        ~a:[a_class ["mb-3"]]
        [ label
            ~a:[a_class ["form-label"]]
            [txt (I18n.t "problems_select_contest")]
        ; contest_select
        ; span
            ~a:[a_class ["text-muted"; "ms-2"; "fst-italic"]]
            [ txt
                ( match cid with
                | 0 -> "No contest selected"
                | cid -> Printf.sprintf "(Contest ID: %d)" cid ) ] ]
    ; (* Import card *)
      Settings_problems_import.render_import_card cid ()
    ; search_bar ()
    ; ( match !error_msg with
      | Some e -> div ~a:[a_class ["alert"; "alert-danger"]] [txt e]
      | None -> div [] )
    ; ( if !loading then
          div
            ~a:[a_class ["text-center"; "py-3"]]
            [Components.Icons.arrow_repeat_icon (); txt "Loading..."]
        else div [] )
    ; problem_list () ]
