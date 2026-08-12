open Js_of_ocaml_tyxml
open Tyxml_js.Html

let render () =
  let contest_id = Helpers.get_current_contest_id () in
  match Helpers.layout () with
  | Helpers.Mobile ->
      [ Components.Sidebar.sidebar ~mobile:true ()
      ; div
          ~a:[a_class ["flex-grow-1"]]
          [ main
              ~a:[a_class ["panel"]]
              [ Components.View_contest_progress.content
                  ~show_progress_only:true ()
              ; Components.View_submissions.content ~contest_id () ] ] ]
  | Helpers.Normal ->
      [ Components.Sidebar.sidebar ~wide:false ()
      ; div
          ~a:[a_class ["flex-grow-1"]]
          [ main
              ~a:[a_class ["panel"]]
              [ Components.View_contest_progress.content
                  ~show_progress_only:true ()
              ; Components.View_submissions.content ~contest_id () ] ] ]
  | Helpers.Wide ->
      [ Components.Sidebar.sidebar ()
      ; div
          ~a:[a_class ["flex-grow-1"]]
          [ main
              ~a:[a_class ["panel"]]
              [ Components.View_contest_progress.content
                  ~show_progress_only:true ()
              ; Components.View_submissions.content ~contest_id () ] ] ]
