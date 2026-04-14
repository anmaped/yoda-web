open Js_of_ocaml_tyxml
open Tyxml_js.Html

let render ~on_success () =
  div
    ~a:[a_class ["form-signin"; "w-100"; "m-auto"]]
    [ img ~src:"yoda.png" ~alt:"Yoda Logo"
        ~a:[a_class ["yoda-logo"; "d-block"; "mx-auto"]; a_width 300]
        ()
    ; Components.Login_form.render ~on_login:on_success ()
    ; p
      ~a:[a_class ["mt-5"; "mb-3"; "text-body-secondary"; "text-center"]]
      [txt "© The Yoda Team 2026"] ]
