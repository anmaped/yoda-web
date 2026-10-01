open Js_of_ocaml
open Js_of_ocaml_tyxml
open Tyxml_js.Html

let content ~contest_id ?(last = 100) () =
  let owner_filter = ref false in
  let reload : (unit -> unit) ref = ref (fun () -> ()) in
  let filter_control =
    label
      ~a:[a_class ["form-check"; "form-switch"; "mb-0"]]
      [ input
          ~a:
            [ a_input_type `Checkbox
            ; a_class ["form-check-input"]
            ; a_onchange (fun ev ->
                  let target =
                    Js.Opt.get
                      (Dom_html.CoerceTo.input
                         (Js.Opt.get ev##.target (fun () -> assert false)) )
                      (fun () -> assert false)
                  in
                  owner_filter := Js.to_bool target##.checked ;
                  !reload () ;
                  false ) ]
          ()
      ; span
          ~a:[a_class ["form-check-label"]]
          [txt (I18n.t "submissions_only_mine")] ]
  in
  let content =
    Submissions_list.content ~contest_id ~last owner_filter reload ()
  in
  section
    ~a:[a_class ["panel-section"; "container"; "py-3"]]
    [ div
        ~a:[a_class ["card"; "shadow-sm"]]
        [ div
            ~a:
              [ a_class
                  [ "card-header"
                  ; "d-flex"
                  ; "justify-content-between"
                  ; "align-items-center" ] ]
            [ h2
                ~a:[a_class ["h5"; "mb-0"]]
                [txt (I18n.t "submissions_recent_title")]
            ; filter_control ]
        ; content ] ]
