open Js_of_ocaml
open Js_of_ocaml_tyxml
open Lwt.Infix

let render () =
  let open Tyxml_js.Html in
  let ul = ul [] in
  Components.Contest_list.content ul () ;
  let section =
    section
      ~a:[a_class ["panel-section"; "container"; "py-3"]]
      [ div
          ~a:[a_class ["card"; "shadow-sm"]]
          [ div
              ~a:[a_class ["card-header"; "bg-white"]]
              [h2 ~a:[a_class ["h5"; "mb-0"]] [txt "Contests"]]
          ; ul ] ]
  in
  let panel =
    div ~a:[a_class ["flex-grow-1"]] [main ~a:[a_class ["panel"]] [section]]
  in
  [Components.Sidebar.sidebar (); panel]
