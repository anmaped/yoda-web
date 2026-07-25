open Js_of_ocaml_tyxml
open Tyxml_js.Html

let render ?(contest_id = 1) ?(problem_id = "") () =
  if problem_id = "" then
    [ div
        ~a:[a_class ["flex-grow-1"]]
        [main ~a:[a_class ["panel"]] [Components.View_problems.content ()]]
    ]
  else
    [ Components.Sidebar.sidebar ()
    ; div
        ~a:[a_class ["flex-grow-1"]]
        [ main
            ~a:[a_class ["panel"]]
            [Components.View_problem.content ~contest_id ~problem_id ()] ] ]
