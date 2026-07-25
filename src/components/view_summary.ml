open Js_of_ocaml_tyxml
open Tyxml_js.Html

let content ~contest_id () =
  div
    ~a:[a_class ["flex-grow-1"]]
    [ main
        ~a:[a_class ["panel"]]
        [ View_contest_progress.content ()
        ; View_problems.content ()
        ; View_submissions.content ~contest_id ~last:15 () ] ]
