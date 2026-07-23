open Js_of_ocaml
open Js_of_ocaml_tyxml
open Js_of_ocaml_lwt
open Tyxml_js.Html
open Lwt.Infix

let render ~on_login () =
  let username =
    input
      ~a:
        [ a_input_type `Email
        ; a_class ["form-control"]
        ; a_id "username"
        ; a_placeholder (I18n.t "login_placeholder_email") ]
      ()
  in
  let password =
    input
      ~a:
        [ a_input_type `Password
        ; a_class ["form-control"]
        ; a_id "password"
        ; a_placeholder (I18n.t "login_placeholder_password") ]
      ()
  in
  let submit_btn =
    button
      ~a:
        [ a_class ["btn"; "btn-primary"; "w-100"; "py-2"]
        ; a_button_type `Submit ]
      [txt (I18n.t "login_sign_in")]
  in
  let error_div =
    div
      ~a:[a_id "login-error"; a_class ["alert"; "alert-danger"; "d-none"]]
      []
  in
  let form_div =
    form
      ~a:[a_method `Post; a_onsubmit (fun _ -> false)]
      [ h1 ~a:[a_class ["h3"; "mb-3"; "fw-normal"]] [txt (I18n.t "login_title")]
      ; error_div
      ; div
          ~a:[a_class ["form-floating"]]
          [username; label ~a:[a_label_for "username"] [txt (I18n.t "login_label_email")]]
      ; div
          ~a:[a_class ["form-floating"]]
          [password; label ~a:[a_label_for "password"] [txt (I18n.t "login_label_password")]]
      ; div
          ~a:[a_class ["form-check"; "text-start"; "my-3"]]
          [ input
              ~a:
                [ a_class ["form-check-input"]
                ; a_input_type `Checkbox
                ; a_id "checkDefault" ]
              ()
          ; label
              ~a:[a_class ["form-check-label"]; a_label_for "checkDefault"]
              [txt (I18n.t "login_remember_me")] ]
      ; submit_btn ]
  in
  let _ =
    Lwt_js_events.clicks (Tyxml_js.To_dom.of_button submit_btn) (fun _ _ ->
        let u = Js.to_string (Tyxml_js.To_dom.of_input username)##.value in
        let p = Js.to_string (Tyxml_js.To_dom.of_input password)##.value in
        Console.console##log (Js.string ("Login user: " ^ u)) ;
        (* Call the API login function *)
        let x =
          Api.Openapi.AuthLoginPostRequest.create ~username:u ~password:p ()
        in
        Api.Helpers.post_json
          (Api.Helpers.base_url ^ "/auth/login")
          (Api.Openapi.AuthLoginPostRequest.to_json x)
        >>= fun (resp, status) ->
        let resp_json_string = Js.to_string (Json.output resp) in
        (* check response type *)
        if status = 200 then (
          Console.console##log
            (Js.string ("Login successful: " ^ resp_json_string)) ;
          (* Parse the response JSON into the appropriate type *)
          let y = Api.Openapi.AuthToken.of_json resp_json_string in
          (* Store the token in local storage *)
          Helpers.set_session_variable "token" y.token ;
          Helpers.set_session_variable "user"
            (Api.Openapi.User.to_json y.user) ;
          Helpers.set_session_variable "error" "" ;
          (* Hide error div on success *)
          let dom_err = Tyxml_js.To_dom.of_div error_div in
          ignore (dom_err##.classList##add (Js.string "d-none")) ;
          on_login () ;
          Lwt.return_unit )
        else (
          Console.console##log
            (Js.string
               ( "Login failed with status: " ^ string_of_int status
               ^ ", response: " ^ resp_json_string ) ) ;
          (* Parse the response JSON into the appropriate type *)
          let x =
            Api.Openapi.AuthLoginPostResponse41.of_json resp_json_string
          in
          Helpers.set_session_variable "error"
            (Api.Openapi.AuthLoginPostResponse41.to_json x) ;
          (* Show error message on failure *)
          let dom_err = Tyxml_js.To_dom.of_div error_div in
          ignore (dom_err##.classList##remove (Js.string "d-none")) ;
          ignore (dom_err##.innerHTML := Js.string x.error) ;
          Lwt.return_unit ) )
  in
  form_div
