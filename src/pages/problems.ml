open Js_of_ocaml
open Js_of_ocaml_tyxml
open Tyxml_js.Html

let render ?(problem_id = "") () =
  div
    ~a:[a_class ["flex-grow-1"]]
    [main ~a:[a_class ["panel"]] [Components.View_problems.content ()]]
