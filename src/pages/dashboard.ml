open Js_of_ocaml
open Js_of_ocaml_tyxml
open Tyxml_js.Html

let render () =
  let contest_id = Helpers.get_current_contest_id () in
  [Components.Sidebar.sidebar (); Components.View_summary.content ~contest_id ()]
