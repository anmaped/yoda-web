open Js_of_ocaml_tyxml
open Tyxml_js.Html
open Lwt.Infix

let render ~on_success () =
  (* check if user is already logged in *)
  match Helpers.get_session_variable "token" with
  | Some p ->
      (* [TODO] need to check if token is valid *)
      Lwt.async (fun () ->
          Api.Helpers.verify_token ()
          >>= fun is_valid ->
          if is_valid then on_success ()
          else (
            Helpers.remove_session_variable "token" ;
            on_success () ) ;
          Lwt.return_unit ) ;
      div []
  | None ->
      div
        ~a:[a_class ["form-signin"; "w-100"; "m-auto"]]
        [ img ~src:"yoda.png" ~alt:"Yoda Logo"
            ~a:[a_class ["yoda-logo"; "d-block"; "mx-auto"]; a_width 300]
            ()
        ; Components.Login_form.render ~on_login:on_success ()
        ; p
            ~a:
              [a_class ["mt-5"; "mb-3"; "text-body-secondary"; "text-center"]]
            [txt "© The Yoda Team 2026"] ]
