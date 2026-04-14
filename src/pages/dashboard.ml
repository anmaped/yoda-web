open Js_of_ocaml_tyxml
open Tyxml_js.Html

let render () =
  [Components.Sidebar.sidebar (); Components.View_summary.content ()]
