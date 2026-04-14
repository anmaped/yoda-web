open Js_of_ocaml_tyxml
open Tyxml_js.Html

let terminal_fill_icon () =
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
              "M0 3a2 2 0 0 1 2-2h12a2 2 0 0 1 2 2v10a2 2 0 0 1-2 2H2a2 2 0 \
               0 1-2-2zm9.5 5.5h-3a.5.5 0 0 0 0 1h3a.5.5 0 0 0 \
               0-1m-6.354-.354a.5.5 0 1 0 .708.708l2-2a.5.5 0 0 0 \
               0-.708l-2-2a.5.5 0 1 0-.708.708L4.793 6.5z" ]
        [] ]

let save_icon () =
  let open Tyxml_js.Svg in
  Tyxml_js.Html.svg
    ~a:
      [ a_width (16., Some `Px)
      ; a_height (16., Some `Px)
      ; a_class ["bi"; "bi-save"]
      ; a_fill (`Color ("currentColor", None))
      ; a_viewBox (0., 0., 16., 16.) ]
    [ path
        ~a:
          [ a_d
              "M2 1a1 1 0 0 0-1 1v12a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1V2a1 1 0 \
               0 0-1-1H9.5a1 1 0 0 0-1 1v7.293l2.646-2.647a.5.5 0 0 1 \
               .708.708l-3.5 3.5a.5.5 0 0 1-.708 0l-3.5-3.5a.5.5 0 1 1 \
               .708-.708L7.5 9.293V2a2 2 0 0 1 2-2H14a2 2 0 0 1 2 2v12a2 2 \
               0 0 1-2 2H2a2 2 0 0 1-2-2V2a2 2 0 0 1 2-2h2.5a.5.5 0 0 1 0 \
               1z" ]
        [] ]

let toolbar () =
  [ div
      ~a:
        [ a_class
            [ "toolbar"
            ; "d-flex"
            ; "justify-content-between"
            ; "align-items-center"
            ; "p-2"
            ; "bg-primary"
            ; "text-white"
            ; "shadow-sm"
            ; "rounded" ] ]
      [ (* Toolbar Title *)
        h4 ~a:[a_class ["m-0"]] [txt (Helpers.get_problem () ^ ": Warmup")]
      ; (* Remove margin from title *)

        (* Button Group on the Right, space between buttons for better
           clarity *)
        div
          ~a:[a_class ["btn-group"; "mr-3"]]
            (* Add margin-right for spacing between button group and
               profile *)
          [ (* Run Button *)
            button
              ~a:
                [ a_id "run-btn"
                ; a_class ["btn"; "btn-success"; "mr-2"]
                ; a_title "Run the code"
                ; a_onclick (fun _ ->
                      Helpers.add_element_to_app
                        (Helpers.make_modal_view "run-modal" "Confirm action"
                           [ txt
                               ( "Do you want to run the '"
                               ^ Helpers.get_problem () ^ "' code?" ) ]
                           (fun _ ->
                             Helpers.hide "spinner-run" () ;
                             false )
                           () ) ;
                      false )
                ; Unsafe.string_attrib "aria-label" "Run" ]
              [terminal_fill_icon (); txt " Run"]
          ; (* Submit Button *)
            button
              ~a:
                [ a_id "save-all-btn"
                ; a_class ["btn"; "btn-warning"; "mr-2"]
                ; a_title "Save all your work"
                ; Unsafe.string_attrib "aria-label" "Submit" ]
              [save_icon (); txt " Submit"] ]
      ; (* User Profile Section (Optional), add some spacing and align it to
           the far right *)
        div
          ~a:
            [a_class ["user-profile"; "d-flex"; "align-items-center"; "ml-3"]]
            (* Add margin-left for spacing *)
          [span [txt (Helpers.username ())]] ]
  ; (* This is a status bar that can show messages like "All changes saved"
       or "Error saving file" *)
    (let last_saved =
       let now = new%js Js_of_ocaml.Js.date_now in
       Js_of_ocaml.Js.to_string now##toLocaleString
     in
     div
       ~a:[a_class ["status-bar"; "text-muted"; "small"; "ml-3"]]
       [ Helpers.make_spinner "run" ()
       ; txt ("All changes saved • Last saved: " ^ last_saved) ] ) ]

let content () =
  section
    ~a:[a_class ["panel-section"; "container-fluid"; "py-3"]]
    (toolbar ())
