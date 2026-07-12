open Js_of_ocaml
open Js_of_ocaml_tyxml
open Tyxml_js.Html

let render () =
  let contest_id = Helpers.get_current_contest_id () in
  [ Components.Sidebar.sidebar ()
  ; div
      ~a:[a_class ["flex-grow-1"]]
      [ main
          ~a:[a_class ["panel"]]
          [ Components.View_contest_progress.content ~show_progress_only:true
              ()
          ; Components.View_submissions.content ~contest_id () ] ] ]
