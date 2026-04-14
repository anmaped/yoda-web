open Js_of_ocaml_tyxml
open Tyxml_js.Html

let content () =
  section
    ~a:[a_class ["panel-section"]]
    [ h2 [txt "Problem A - Warmup"]
    ; p [txt "Submit your solution below."]
    ; form
        ~a:[a_class ["submit-form"]]
        [ label [txt "Language"]
        ; select
            [ option ~a:[a_value "cpp"] (txt "C++17")
            ; option ~a:[a_value "ocaml"] (txt "OCaml")
            ; option ~a:[a_value "python"] (txt "Python 3") ]
        ; label [txt "Source code file"]
        ; input ~a:[a_input_type `File] ()
        ; button ~a:[a_button_type `Submit] [txt "Submit"] ] ]
