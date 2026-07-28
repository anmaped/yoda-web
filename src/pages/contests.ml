open Js_of_ocaml_tyxml

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
              ~a:[a_class ["card-header"]]
              [h2 ~a:[a_class ["h5"; "mb-0"]] [txt (I18n.t "contests_title")]]
          ; ul ] ]
  in
  let panel =
    div ~a:[a_class ["flex-grow-1"]] [main ~a:[a_class ["panel"]] [section]]
  in
  [Components.Sidebar.sidebar (); panel]
