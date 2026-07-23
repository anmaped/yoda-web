open Js_of_ocaml_tyxml
open Tyxml_js.Html
open I18n
let t = t

let content () =
  section
    ~a:[a_class ["panel-section"]]
    [ h2 [txt (t "problem_submit_solution")]
    ; p [txt (t "problem_submit_solution")]
    ; form
        ~a:[a_class ["submit-form"]]
        [ label [txt (t "problem_language_label")]
        ; select
            [ option ~a:[a_value "cpp"] (txt (t "problem_lang_cpp"))
            ; option ~a:[a_value "ocaml"] (txt (t "problem_lang_ocaml"))
            ; option ~a:[a_value "python"] (txt (t "problem_lang_python")) ]
        ; label [txt (t "problem_source_file_label")]
        ; input ~a:[a_input_type `File] ()
        ; button ~a:[a_button_type `Submit] [txt (t "problem_submit_btn")] ] ]
