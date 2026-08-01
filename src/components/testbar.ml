open Js_of_ocaml_tyxml
open Tyxml_js.Html

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
                  ; a_onclick (fun _ev ->
                        Model.Tests.remove_test t.id ;
                        Helpers.remove_element_by_id parent_id ;
                        false (* prevent default *) ) ]
                [Icons.x_square_fill ()]
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
                        [txt (I18n.t "test_type_text")]
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
                        [txt (I18n.t "test_type_json")] ]
                ; textarea
                    ~a:
                      [ a_class ["form-control"; "mb-2"]
                      ; a_placeholder "Enter test input..." ]
                    (txt t.input)
                ; ( match t.kind with
                  | `Json when not (Helpers.is_valid_json t.input) ->
                      div
                        ~a:[a_class ["text-danger"]]
                        [txt (I18n.t "test_invalid_json")]
                  | _ -> txt "" ) ] ] ] ]

let load_state () = Model.Tests.load_tests ()

let save_state () =
  let tests_json = Model.Tests.export () in
  Helpers.set_local_variable "yoda-state-tests" tests_json

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
      [Icons.plus_square_icon ()]
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
