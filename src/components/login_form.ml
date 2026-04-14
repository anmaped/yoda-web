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
        ; a_placeholder "name@example.com" ]
      ()
  in
  let password =
    input
      ~a:
        [ a_input_type `Password
        ; a_class ["form-control"]
        ; a_id "password"
        ; a_placeholder "Password" ]
      ()
  in
  let submit_btn =
    button
      ~a:
        [ a_class ["btn"; "btn-primary"; "w-100"; "py-2"]
        ; a_button_type `Submit ]
      [txt "Sign in"]
  in
  let form_div =
    form
      [ h1 ~a:[a_class ["h3"; "mb-3"; "fw-normal"]] [txt "Please sign in"]
      ; div
          ~a:[a_class ["form-floating"]]
          [ username
          ; label ~a:[a_label_for "username"] [txt "Email address"] ]
      ; div
          ~a:[a_class ["form-floating"]]
          [ password
          ; label ~a:[a_label_for "password"] [txt "Password"] ]
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
              [txt "Remember me"] ]
      ; submit_btn ]
  in
  let _ =
    Lwt_js_events.clicks (Tyxml_js.To_dom.of_button submit_btn) (fun _ _ ->
        let u = Js.to_string (Tyxml_js.To_dom.of_input username)##.value in
        let p = Js.to_string (Tyxml_js.To_dom.of_input password)##.value in
        Api.login u p
        >>= fun resp ->
        Js.Optdef.iter resp##.token (fun t ->
            Js.Optdef.iter Dom_html.window##.localStorage (fun storage ->
                storage##setItem (Js.string "token") t ) ) ;
        on_login () ;
        Lwt.return_unit )
  in
  form_div
