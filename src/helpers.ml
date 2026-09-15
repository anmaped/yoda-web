open Js_of_ocaml
open Js_of_ocaml_tyxml

(* escape and unescape JSON strings for safe transmission *)

(* Strip surrounding double quotes from JSON string *)
let cleanup_json_string json_str =
  let len = String.length json_str in
  if len >= 2 && json_str.[0] = '"' && json_str.[len - 1] = '"' then
    String.sub json_str 1 (len - 2)
  else json_str

let escape_json_string s =
  let b = Buffer.create (String.length s + 16) in
  String.iter
    (function
      | '"' -> Buffer.add_string b "\\\""
      | '\\' -> Buffer.add_string b "\\\\"
      | '\n' -> Buffer.add_string b "\\n"
      | '\r' -> Buffer.add_string b "\\r"
      | '\t' -> Buffer.add_string b "\\t"
      | c -> Buffer.add_char b c )
    s ;
  Buffer.contents b

let unscape_json_string s =
  let b = Buffer.create (String.length s) in
  let rec aux i =
    if i >= String.length s then ()
    else if s.[i] = '\\' && i + 1 < String.length s then (
      match s.[i + 1] with
      | '"' ->
          Buffer.add_char b '"' ;
          aux (i + 2)
      | '\\' ->
          Buffer.add_char b '\\' ;
          aux (i + 2)
      | 'n' ->
          Buffer.add_char b '\n' ;
          aux (i + 2)
      | 'r' ->
          Buffer.add_char b '\r' ;
          aux (i + 2)
      | 't' ->
          Buffer.add_char b '\t' ;
          aux (i + 2)
      | _ ->
          Buffer.add_char b s.[i] ;
          aux (i + 1) )
    else (
      Buffer.add_char b s.[i] ;
      aux (i + 1) )
  in
  aux 0 ; Buffer.contents b

let remove_first_element_from_app element =
  let doc = Dom_html.document in
  match Js.Opt.to_option (doc##querySelector (Js.string element)) with
  | Some el ->
      ignore (Js.Unsafe.meth_call el "remove" [||]) ;
      Console.console##log (Js.string ("Element removed: " ^ element))
  | None ->
      Console.console##log (Js.string ("Element not found: " ^ element))

let add_element_to_app element =
  let app_div = Dom_html.getElementById "app" in
  let dom_element = Tyxml_js.To_dom.of_div element in
  Dom.appendChild app_div dom_element ;
  Console.console##log
    (Js.string ("Element added: " ^ Js.to_string dom_element##.id))

let is_mobile () =
  let width = Dom_html.window##.innerWidth in
  width < 768

let is_wide_desktop () =
  let width = Dom_html.window##.innerWidth in
  width >= 1200

type layout = Mobile | Normal | Wide

let layout () =
  if is_wide_desktop () then Wide
  else if is_mobile () then Mobile
  else Normal

(* Local Storage and Session Storage Helpers *)
let set_session_variable key value =
  Js.Optdef.iter Dom_html.window##.sessionStorage (fun storage ->
      storage##setItem (Js.string key) (Js.string value) )

let get_session_variable key =
  match Js.Optdef.to_option Dom_html.window##.sessionStorage with
  | Some storage -> Js.Opt.to_option (storage##getItem (Js.string key))
  | None -> None

let remove_session_variable key =
  Js.Optdef.iter Dom_html.window##.sessionStorage (fun storage ->
      ignore (storage##removeItem (Js.string key)) )

(* Cookie helpers *)
let exists_cookie_variable name =
  let cookies = Js.to_string Dom_html.document##.cookie in
  let cookie_list = Astring.String.cuts ~sep:";" cookies in
  List.exists
    (fun c -> Astring.String.is_prefix ~affix:(name ^ "=") c)
    cookie_list

let remove_cookies_variable name =
  let expired =
    Js.string (name ^ "=;expires=Thu, 01 Jan 1970 00:00:00 GMT;path=/")
  in
  Dom_html.document##.cookie := expired ;
  Console.console##log (Js.string ("Cookie removed: " ^ name))

let get_username () =
  match get_session_variable "user" with
  | Some t -> (
      let json_str = Js.to_string t in
      try
        let raw =
          Yojson.Basic.from_string json_str
          |> Yojson.Basic.Util.member "username"
          |> Yojson.Basic.to_string
        in
        (* Strip surrounding double quotes from JSON string *)
        cleanup_json_string raw
      with _ -> "Guest" )
  | None -> "Guest"

let secure_local_storage_sync () =
  let value : Js.Unsafe.any Js.optdef =
    Js.Unsafe.get Dom_html.window "secureLocalStorageSync"
  in
  Js.Optdef.to_option value

let preloaded_local_storage_user : string option ref = ref None

let ensure_local_cache_preloaded () : unit Lwt.t =
  match secure_local_storage_sync () with
  | None -> Lwt.return_unit
  | Some bridge ->
      let user_id = get_username () in
      if !preloaded_local_storage_user = Some user_id then Lwt.return_unit
      else
        let promise : Js.Unsafe.any Promise.t =
          Js.Unsafe.meth_call bridge "preloadAll"
            [|Js.Unsafe.inject (Js.string user_id)|]
          |> Promise.of_any
        in
        let waiter, wakener = Lwt.wait () in
        ignore
          (Promise.then_
             ~on_error:(fun _err ->
               if Lwt.is_sleeping waiter then
                 Lwt.wakeup_exn wakener (Failure "preloadAll failed") ;
               Promise.resolve () )
             (fun _result ->
               preloaded_local_storage_user := Some user_id ;
               if Lwt.is_sleeping waiter then Lwt.wakeup wakener () ;
               Promise.resolve () )
             promise ) ;
        waiter

let set_local_variable key value =
  match secure_local_storage_sync () with
  | Some bridge ->
      let user_id = get_username () in
      ignore
        (Js.Unsafe.meth_call bridge "setItem"
           [| Js.Unsafe.inject (Js.string user_id)
            ; Js.Unsafe.inject (Js.string key)
            ; Js.Unsafe.inject (Js.string value) |] )
  | None ->
      Js.Optdef.iter Dom_html.window##.localStorage (fun storage ->
          storage##setItem (Js.string key) (Js.string value) )

let trace msg () : unit =
  ignore
    (Js.Unsafe.meth_call
       (Js.Unsafe.get Js.Unsafe.global "console")
       "trace"
       [|Js.Unsafe.inject (Js.string ("Trace: " ^ msg))|] )

let get_local_variable key =
  (*trace "get_local_variable" () ;*)
  match secure_local_storage_sync () with
  | Some bridge ->
      let user_id = get_username () in
      let value : Js.js_string Js.t Js.opt =
        Js.Unsafe.meth_call bridge "getItem"
          [| Js.Unsafe.inject (Js.string user_id)
           ; Js.Unsafe.inject (Js.string key) |]
      in
      (* print value *)
      Console.console##log
        (Js.string
           ( "Retrieved " ^ key ^ " : "
           ^ Js.to_string (Js.Opt.get value (fun _ -> Js.string "Not found!"))
           ) ) ;
      Js.Opt.to_option value
  | None -> (
    match Js.Optdef.to_option Dom_html.window##.localStorage with
    | Some storage -> Js.Opt.to_option (storage##getItem (Js.string key))
    | None -> None )

let is_user_role role =
  match get_session_variable "user" with
  | Some t -> (
      let json_str = Js.to_string t in
      try
        let raw =
          Yojson.Basic.from_string json_str
          |> Yojson.Basic.Util.member "role"
          |> Yojson.Basic.to_string
        in
        Astring.String.is_suffix ~affix:role
          (String.lowercase_ascii (cleanup_json_string raw))
      with _ -> false )
  | None -> false

let is_admin () : bool = is_user_role "admin"

let is_judge () : bool = is_user_role "judge"

let is_judge_or_admin () : bool = is_judge () || is_admin ()

let is_valid_json s =
  try
    ignore (Yojson.Basic.from_string s) ;
    true
  with _ -> false

let get_element_by_id id =
  match
    Js.Opt.to_option (Dom_html.document##getElementById (Js.string id))
  with
  | None -> failwith ("Missing element #" ^ id)
  | Some el -> el

let append_child_by_id parent_id child =
  let parent = get_element_by_id parent_id in
  (* Convert Tyxml element to DOM node *)
  let child_node = Tyxml_js.To_dom.of_element child in
  Dom.appendChild parent child_node ;
  (* Safely coerce to Dom_html.element to access .##id *)
  let child_el_opt =
    Dom_html.CoerceTo.element child_node |> Js.Opt.to_option
  in
  let child_id =
    match child_el_opt with
    | Some el -> Js.to_string el##.id
    | None -> "(unknown)"
  in
  Console.console##log
    (Js.string ("Child \"" ^ child_id ^ "\" appended to #" ^ parent_id))

let remove_element_by_id id =
  let el = get_element_by_id id in
  ignore (Js.Unsafe.meth_call el "remove" [||]) ;
  Console.console##log (Js.string ("Element removed: #" ^ id))

(* Navigation helpers *)

(** Navigates to the specified path and reloads the page *)
let navigate_to_with_reload path =
  Dom_html.window##.history##pushState
    Js.null (Js.string "")
    (Js.Opt.return (Js.string path)) ;
  Dom_html.window##.location##reload

(** Triggers a resize event *)
let trigger_resize () =
  let event =
    Js.Unsafe.new_obj
      (Js.Unsafe.pure_js_expr "Event")
      [|Js.Unsafe.inject (Js.string "resize")|]
  in
  ignore (Dom_html.window##dispatchEvent event)

(** Triggers a render event *)
let trigger_render () =
  let event =
    Js.Unsafe.new_obj
      (Js.Unsafe.pure_js_expr "Event")
      [|Js.Unsafe.inject (Js.string "render")|]
  in
  ignore (Dom_html.window##dispatchEvent event)

(** Navigates to the specified path and triggers a render event *)
let navigate_to path =
  Dom_html.window##.history##pushState
    Js.null (Js.string "")
    (Js.Opt.return (Js.string path)) ;
  trigger_render ()

(* Current contest ID helpers *)

(** Returns the ID of the currently selected contest *)
let get_current_contest_id () =
  match get_local_variable "yoda-state-contest-id" with
  | Some id -> int_of_string (Js.to_string id)
  | None -> navigate_to "#contests" ; 0

(** Sets the ID of the currently selected contest *)
let set_current_contest_id id =
  set_local_variable "yoda-state-contest-id" (string_of_int id) ;
  Console.console##log
    (Js.string ("Current contest_id set to: " ^ string_of_int id))

(** Authentication helpers *)
let auth_token () =
  match get_session_variable "token" with
  | Some t -> t
  | None -> Js.string ""

let clear_auth_state () =
  Js.Optdef.iter Dom_html.window##.sessionStorage (fun storage ->
      storage##removeItem (Js.string "token") ;
      storage##removeItem (Js.string "user") ;
      storage##removeItem (Js.string "error") ) ;
  remove_cookies_variable "dream.session"

let redirect_to_login () =
  let current_hash = Js.to_string Dom_html.window##.location##.hash in
  if current_hash <> "#login" then
    Dom_html.window##.location##.hash := Js.string "#login"

let handle_unauthorized ?(redirect_on_unauthorized = true)
    (resp : Js_of_ocaml_lwt.XmlHttpRequest.http_frame) =
  if redirect_on_unauthorized && resp.code = 401 then (
    clear_auth_state () ; redirect_to_login () )

(** Helper functions for managing post-login redirects *)
let key_post_login_redirect = "yoda-post-login-redirect"

let key_login_notice = "yoda-login-notice"

let remember_post_login_redirect hash =
  if hash <> "" && hash <> "#login" && hash <> "#logout" then
    set_session_variable key_post_login_redirect hash

let consume_post_login_redirect () =
  match get_session_variable key_post_login_redirect with
  | Some h ->
      remove_session_variable key_post_login_redirect ;
      Some (Js.to_string h)
  | None -> None

let set_session_expired_notice () =
  set_session_variable key_login_notice "session-expired"

let consume_session_expired_notice () =
  match get_session_variable key_login_notice with
  | Some v ->
      remove_session_variable key_login_notice ;
      Js.to_string v = "session-expired"
  | None -> false

let navigate_after_login ?(default_hash = "#contests") () =
  match consume_post_login_redirect () with
  | Some hash when hash <> "" && hash <> "#login" && hash <> "#logout" ->
      navigate_to_with_reload hash
  | _ -> navigate_to_with_reload default_hash
