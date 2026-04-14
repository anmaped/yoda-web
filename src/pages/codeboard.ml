open Js_of_ocaml_tyxml
open Tyxml_js.Html

let init () = Components.Editor.init ()

let render () =
  let content =
    div
      ~a:[a_class ["flex-grow-1"]; a_style "height: 100%;"]
      [ main
          ~a:
            [ a_class ["d-flex"; "flex-column"; "panel"]
            ; a_style "height: 100%;" ]
          [ Components.Codebar.content ()
          ; Components.Testbar.content ()
          ; Components.Tabbar.content ()
          ; Components.Editor.content () ] ]
  in
  let content_ =
    div
      ~a:[a_class ["flex-grow-1"]; a_style "height: 100%;"]
      [ main
          ~a:
            [ a_class ["d-flex"; "flex-column"; "panel"]
            ; a_style "height: 100%;" ]
          [ Components.Codebar.content ()
          ; div
              ~a:
                [ a_class ["d-flex"; "flex-grow-1"]
                ; a_style "height: 100%; min-height: 0;" ]
              [ (* LEFT: tabbar + editor *)
                div
                  ~a:[a_class ["flex-grow-1"; "d-flex"; "flex-column"]]
                  [Components.Tabbar.content (); Components.Editor.content ()]
              ; (* RIGHT: testbar (only spans tabbar + editor) *)
                aside
                  ~a:
                    [ a_style
                        "width: 30%; border-left: 1px solid #ddd; \
                         background: #f8f9fa; height: 100%; overflow-y: auto;" ]
                  [Components.Testbar.content ~sidebyside:false ()] ] ] ]
  in
  if Helpers.is_mobile () then [content]
  else if Helpers.is_wide_desktop () then
    [Components.Sidebar.sidebar (); content_]
  else [Components.Sidebar.sidebar (); content]
