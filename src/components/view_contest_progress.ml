open Js_of_ocaml_tyxml
open Tyxml_js.Html

let content ?(show_progress_only = false) () =
  let contest_overview =
    if not show_progress_only then
      [ h2 ~a:[a_class ["mb-1"]] [txt "🏁 Winter Practice"]
      ; p ~a:[a_class ["text-muted"; "mb-3"]] [txt "Contest overview"]
      ; ul
          ~a:[a_class ["list-unstyled"; "mb-3"]]
          [ li
              [ span ~a:[a_class ["fw-semibold"]] [txt "Status: "]
              ; span ~a:[a_class ["badge"; "bg-success"]] [txt "Running"] ]
          ; li
              [ span ~a:[a_class ["fw-semibold"]] [txt "Time Left: "]
              ; span ~a:[a_class ["font-monospace"]] [txt "02:14:36"] ] ]
      ; div ~a:[a_class ["mb-1"; "small"; "text-muted"]] [txt "Progress"] ]
    else
      [ div
          ~a:[a_class ["mb-1"; "small"; "text-muted"]]
          [txt "Contest Progress"] ]
  in
  section
    ~a:[a_class ["panel-section"; "container"; "py-3"]]
    [ div
        ~a:[a_class ["contest-card"; "rounded"; "p-3"; "shadow-sm"]]
        ( contest_overview
        @ [ div
              ~a:[a_class ["progress"]; a_style "height: 8px;"]
              [ div
                  ~a:
                    [ a_class ["progress-bar"; "bg-info"]
                    ; a_style "width: 68%;" ]
                  [] ] ] ) ]
