open Js_of_ocaml
open Js_of_ocaml_tyxml
open Tyxml_js.Html
open Lwt.Infix

let refresh_login_i18n () =
  Components.Login_form.refresh_i18n () ;
  Components.Login_form.set_text "login-language-label" (I18n.t "settings_language_label") ;
  Components.Login_form.set_text "login-footer" (I18n.t "login_footer") ;
  Components.Login_form.set_text "login-session-expired-alert" (I18n.t "login_session_expired") ;
  let hash = Js.to_string Dom_html.window##.location##.hash in
  Dom_html.document##.title :=
    Js.string (hash ^ " - " ^ I18n.t "sidebar_app_name")

let render ~on_success () =
  let show_session_expired = Helpers.consume_session_expired_notice () in
  let session_expired_alert =
    if show_session_expired then
      [ div
          ~a:[a_id "login-session-expired-alert"; a_class ["alert"; "alert-warning"; "mt-2"]]
          [txt (I18n.t "login_session_expired")] ]
    else []
  in
  (* check if user is already logged in *)
  match Helpers.get_session_variable "token" with
  | Some _token ->
      (* need to check if token is valid *)
      Lwt.async (fun () ->
          Api.Helpers.verify_token ()
          >>= fun is_valid ->
          if is_valid then on_success ()
          else Helpers.remove_session_variable "token" ;
          if Helpers.exists_cookie_variable "dream.session" then
            Helpers.remove_cookies_variable "dream.session" ;
          Lwt.return_unit ) ;
      div []
  | None ->
      let current_lang = I18n.language_to_code (I18n.current_language ()) in
      let language_selector =
        div
          ~a:[a_class ["login-language-row"]]
          [ label
              ~a:
                [ a_id "login-language-label"
                ; a_class ["form-label"; "login-language-label"]
                ; a_label_for "login-language" ]
              [txt (I18n.t "settings_language_label")]
          ; select
              ~a:
                [ a_id "login-language"
                ; a_class ["form-select"; "form-select-sm"; "login-language-select"]
                ; a_onchange (fun ev ->
                      let target =
                        Js.Opt.get
                          (Dom_html.CoerceTo.select
                             (Js.Opt.get ev##.target (fun () -> assert false)) )
                          (fun () -> assert false)
                      in
                      I18n.set_language
                        (I18n.language_of_code (Js.to_string target##.value)) ;
                      refresh_login_i18n () ;
                      false ) ]
              (List.map
                 (fun (lang, name) ->
                   let code = I18n.language_to_code lang in
                   option
                     ~a:
                       ([a_value code]
                       @ if code = current_lang then [a_selected ()] else [])
                     (txt name) )
                 I18n.languages ) ]
      in
      div
        ~a:[a_class ["form-signin"; "w-100"; "m-auto"]]
        [ img ~src:Blobs.yoda_logo_url ~alt:"Yoda Logo"
            ~a:[a_class ["yoda-logo"; "d-block"; "mx-auto"]; a_width 300]
            ()
        ; div session_expired_alert
        ; language_selector
        ; Components.Login_form.render ~on_login:on_success ()
        ; p
            ~a:
              [ a_id "login-footer"
              ; a_class ["mt-5"; "mb-3"; "text-body-secondary"; "text-center"] ]
            [txt (I18n.t "login_footer")] ]
