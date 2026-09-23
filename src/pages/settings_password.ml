open Js_of_ocaml
open Lwt.Infix
open Js_of_ocaml_tyxml
open Tyxml_js.Html

let current_password = ref ""

let new_password = ref ""

let confirm_password = ref ""

let busy = ref false

let error = ref None

let notice = ref None

let input_value ev =
  let target =
    Js.Opt.get
      (Dom_html.CoerceTo.input
         (Js.Opt.get ev##.target (fun () -> assert false)))
      (fun () -> assert false)
  in
  Js.to_string target##.value

let reset_form () =
  current_password := "" ;
  new_password := "" ;
  confirm_password := ""

let submit () =
  let current = String.trim !current_password
  and new_value = String.trim !new_password
  and confirmation = String.trim !confirm_password in
  error := None ;
  notice := None ;
  if current = "" || new_value = "" || confirmation = "" then
    error := Some (I18n.t "password_validation_required")
  else if new_value <> confirmation then
    error := Some (I18n.t "password_validation_mismatch")
  else if current = new_value then
    error := Some (I18n.t "password_validation_same")
  else begin
    busy := true ;
    ignore
      (Api.Helpers.post_auth_password ~current_password:current
         ~new_password:new_value ()
       >>= fun (_json, code) ->
       busy := false ;
       if code = 200 || code = 204 then (
         reset_form () ;
         notice := Some (I18n.t "password_notice_updated") )
       else if code = 401 || code = 403 then
         error := Some (I18n.t "password_error_current")
       else
         error :=
           Some
             (Printf.sprintf "%s (HTTP %d)"
                (I18n.t "password_error_update") code) ;
       Helpers.trigger_render () ;
       Lwt.return () )
  end ;
  Helpers.trigger_render ()

let password_input ~label_text ~value ~on_input () =
  div
    ~a:[a_class ["mb-3"]]
    [ label ~a:[a_class ["form-label"]] [txt label_text]
    ; input
        ~a:
          [ a_input_type `Password
          ; a_class ["form-control"]
          ; a_value !value
          ; a_oninput (fun ev -> on_input (input_value ev) ; false) ]
        () ]

let render_password_tab () =
  let form =
    Settings_helpers.section_card
      (I18n.t "password_change_title")
    [ p ~a:[a_class ["text-body-secondary"]]
          [txt (I18n.t "password_change_description")]
      ; password_input ~label_text:(I18n.t "password_current_label")
          ~value:current_password
          ~on_input:(fun value -> current_password := value) ()
      ; password_input ~label_text:(I18n.t "password_new_label") ~value:new_password
          ~on_input:(fun value -> new_password := value) ()
      ; password_input ~label_text:(I18n.t "password_confirm_label")
          ~value:confirm_password
          ~on_input:(fun value -> confirm_password := value) ()
      ; button
          ~a:
            ( [ a_class ["btn"; "btn-primary"]
              ; a_onclick (fun _ -> ignore (submit ()) ; false) ]
            @ if !busy then [a_disabled ()] else [] )
          [txt (I18n.t "password_change_submit")]
      ; ( match !error with
        | None -> div []
        | Some message ->
            div ~a:[a_class ["alert"; "alert-danger"; "mt-3"]] [txt message] )
      ; ( match !notice with
        | None -> div []
        | Some message ->
            div ~a:[a_class ["alert"; "alert-success"; "mt-3"]] [txt message] ) ]
  in
  form
