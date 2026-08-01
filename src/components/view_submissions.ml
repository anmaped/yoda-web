open Js_of_ocaml_tyxml
open Tyxml_js.Html

let content ~contest_id ?(last = 100) () =
  section
    ~a:[a_class ["panel-section"; "container"; "py-3"]]
    [ div
        ~a:[a_class ["card"; "shadow-sm"]]
        [ div
            ~a:[a_class ["card-header"]]
            [h2 ~a:[a_class ["h5"; "mb-0"]] [txt (I18n.t "submissions_recent_title")]]
        ; Submissions_list.content ~contest_id ~last () ] ]
