open Js_of_ocaml
open Js_of_ocaml_tyxml
open Lwt.Infix

let render () =
  let open Tyxml_js.Html in
  let ul = ul [] in
  Components.Contest_list.content ul () ;
  [Components.Sidebar.sidebar (); div [h2 [txt "Contests"]; ul]]
