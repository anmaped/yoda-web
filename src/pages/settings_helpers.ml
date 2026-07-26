open Js_of_ocaml
open Js_of_ocaml_tyxml
open Tyxml_js.Html

let section_card title content =
  div
    ~a:[a_class ["card"; "mb-3"]]
    [ div
        ~a:[a_class ["card-header"]]
        [h6 ~a:[a_class ["card-title"; "mb-0"]] [txt title]]
    ; div ~a:[a_class ["card-body"]] content ]

let toggle_switch ~checked ~label_text ~on_change () =
  let attrs =
    [ a_input_type `Checkbox
    ; a_class ["form-check-input"]
    ; a_id ("toggle-" ^ label_text)
    ; a_onchange (fun ev ->
          let target =
            Js.Opt.get
              (Dom_html.CoerceTo.input
                 (Js.Opt.get ev##.target (fun () -> assert false)) )
              (fun () -> assert false)
          in
          on_change (Js.to_bool target##.checked) ;
          false ) ]
    @ if checked then [a_checked ()] else []
  in
  div
    ~a:[a_class ["d-flex"; "justify-content-between"; "align-items-center"]]
    [ label [txt label_text]
    ; div
        ~a:[a_class ["form-check"; "form-switch"]]
        [ input ~a:attrs ()
        ; label
            ~a:
              [ a_class ["form-check-label"]
              ; a_label_for ("toggle-" ^ label_text) ]
            [] ] ]

let select_options opts current =
  List.map
    (fun o ->
      option
        ~a:([a_value o] @ if o = current then [a_selected ()] else [])
        (txt o) )
    opts
