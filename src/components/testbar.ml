open Js_of_ocaml_tyxml
open Tyxml_js.Html

let plus_square_icon () =
  let open Tyxml_js.Svg in
  Tyxml_js.Html.svg
    ~a:
      [ a_class ["bi"; "bi-plus-square"]
      ; a_width (32., Some `Px)
      ; a_height (32., Some `Px)
      ; a_fill (`Color ("currentColor", None))
      ; a_viewBox (-0., -0., 16., 16.) ]
    [ path
        ~a:
          [ a_d
              "M14 1a1 1 0 0 1 1 1v12a1 1 0 0 1-1 1H2a1 1 0 0 1-1-1V2a1 1 0 \
               0 1 1-1zM2 0a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h12a2 2 0 0 0 \
               2-2V2a2 2 0 0 0-2-2z" ]
        []
    ; path
        ~a:
          [ a_d
              "M8 4a.5.5 0 0 1 .5.5v3h3a.5.5 0 0 1 0 1h-3v3a.5.5 0 0 1-1 \
               0v-3h-3a.5.5 0 0 1 0-1h3v-3A.5.5 0 0 1 8 4" ]
        [] ]

let x_square_fill () =
  let open Tyxml_js.Svg in
  Tyxml_js.Html.svg
    ~a:
      [ a_class ["bi"; "bi-x-square-fill"]
      ; a_width (24., Some `Px)
      ; a_height (24., Some `Px)
      ; a_fill (`Color ("currentColor", None))
      ; a_viewBox (-0., -0., 16., 16.) ]
    [ path
        ~a:
          [ a_d
              "M2 0a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V2a2 2 0 \
               0 0-2-2zm3.354 4.646L8 7.293l2.646-2.647a.5.5 0 0 1 \
               .708.708L8.707 8l2.647 2.646a.5.5 0 0 1-.708.708L8 \
               8.707l-2.646 2.647a.5.5 0 0 1-.708-.708L7.293 8 4.646 \
               5.354a.5.5 0 1 1 .708-.708" ]
        [] ]

let accordion (t : Model.Tests.test) =
  let id_suffix = string_of_int t.id in
  let parent_id = "unittest-" ^ id_suffix in
  let collapse_id = "collapse-" ^ id_suffix in
  div
    ~a:[a_class ["accordion"; "accordion-flush"; "mb-2"]; a_id parent_id]
    [ div
        ~a:[a_class ["accordion-item"]]
        [ h2
            ~a:[a_class ["accordion-header"; "d-flex"; "align-items-center"]]
            [ button
                ~a:
                  [ a_class ["btn"; "btn-sm"; "btn-danger"; "ms-1"; "me-2"]
                  ; a_user_data "test-id" id_suffix
                  ; a_title ("Delete test " ^ id_suffix)
                  ; a_onclick (fun ev ->
                        Model.Tests.remove_test t.id ;
                        Helpers.remove_element_by_id parent_id ;
                        false (* prevent default *) ) ]
                [x_square_fill ()]
            ; button
                ~a:
                  [ a_class ["accordion-button"; "collapsed"; "flex-grow-1"]
                  ; a_button_type `Button
                  ; a_user_data "bs-toggle" "collapse"
                  ; a_user_data "bs-target" ("#" ^ collapse_id) ]
                [txt ("Test " ^ id_suffix)] ]
        ; div
            ~a:[a_id collapse_id; a_class ["accordion-collapse"; "collapse"]]
            [ div
                ~a:[a_class ["accordion-body"; "form-label"]]
                [ (* Toggle *)
                  div
                    ~a:[a_class ["btn-group"; "mb-2"]]
                    [ input
                        ~a:
                          ( [ a_input_type `Radio
                            ; a_class ["btn-check"]
                            ; a_name ("type-" ^ id_suffix)
                            ; a_id ("type-text-" ^ id_suffix) ]
                          @ if t.kind = `Text then [a_checked ()] else [] )
                        ()
                    ; label
                        ~a:
                          [ a_class ["btn"; "btn-outline-primary"; "btn-sm"]
                          ; a_label_for ("type-text-" ^ id_suffix) ]
                        [txt "Text"]
                    ; input
                        ~a:
                          ( [ a_input_type `Radio
                            ; a_class ["btn-check"]
                            ; a_name ("type-" ^ id_suffix)
                            ; a_id ("type-json-" ^ id_suffix) ]
                          @ if t.kind = `Json then [a_checked ()] else [] )
                        ()
                    ; label
                        ~a:
                          [ a_class ["btn"; "btn-outline-primary"; "btn-sm"]
                          ; a_label_for ("type-json-" ^ id_suffix) ]
                        [txt "JSON"] ]
                ; textarea
                    ~a:
                      [ a_class ["form-control"; "mb-2"]
                      ; a_placeholder "Enter test input..." ]
                    (txt t.input)
                ; ( match t.kind with
                  | `Json when not (Helpers.is_valid_json t.input) ->
                      div ~a:[a_class ["text-danger"]] [txt "Invalid JSON"]
                  | _ -> txt "" ) ] ] ] ]

let content ?(sidebyside = true) () =
  let button =
    button
      ~a:
        [ a_class ["btn"; "btn-sm"; "btn-primary"; "mb-2"]
        ; a_id "add-test-btn"
        ; a_title "Add a new test case"
        ; a_onclick (fun _ ->
              let test = Model.Tests.add_test () in
              Helpers.append_child_by_id "testbar" (accordion test) ;
              false ) ]
      [plus_square_icon ()]
  in
  section
    ~a:[a_class ["panel-section"; "container-fluid"; "py-1"]]
    [ div
        [ ( if not sidebyside then button
            else txt "" (* Show button only in side-by-side mode *) )
        ; div
            ~a:[a_id "testbar"; a_class ["d-flex"; "gap-3"; "flex-wrap"]]
            ( (if sidebyside then button else txt "")
            ::
            ( Model.Tests.load_tests () ;
              List.map accordion !Model.Tests.tests |> List.rev ) ) ] ]
