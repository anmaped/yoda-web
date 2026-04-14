open Js_of_ocaml_tyxml
open Tyxml_js.Html

let render () =
  [ Components.Sidebar.sidebar ()
  ; div
      ~a:[a_class ["flex-grow-1"]]
      [ main
          ~a:[a_class ["panel"]]
          [ Components.View_contest_progress.content ~show_progress_only:true
              ()
          ; Components.View_submissions.content () ] ] ]
