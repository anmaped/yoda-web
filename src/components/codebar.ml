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

let make_spinner id =
  div
    ~a:
      [ a_id ("spinner-" ^ id)
      ; a_class ["spinner-border"; "spinner-border-sm"; "text-primary"]
      ; a_role ["status"] ]
    [span ~a:[a_class ["visually-hidden"]] [txt " "]]

let spinner = make_spinner "run"

let status_message =
  span
    ~a:[a_id "status-message"; a_class ["text-muted"; "small"; "ml-3"]]
    [txt (I18n.t "codebar_all_changes_saved")]

let status_bar =
  div
    ~a:[a_class ["status-bar"; "text-muted"; "small"; "ml-3"]]
    [status_message; spinner]

let update_status_bar ?(no_time = false) msg =
  let last_saved =
    let now = new%js Js_of_ocaml.Js.date_now in
    Js_of_ocaml.Js.to_string now##toLocaleString
  in
  let el = Tyxml_js.To_dom.of_span status_message in
  el##.textContent :=
    Js_of_ocaml.Js.some
      (Js_of_ocaml.Js.string
         (msg ^ if no_time then "" else " • " ^ last_saved) )

let hide s =
  let el = Tyxml_js.To_dom.of_div s in
  el##.style##.display := Js_of_ocaml.Js.string "none" ;
  Js_of_ocaml.Console.console##log
    (Js_of_ocaml.Js.string
       ("Element hidden: " ^ Js_of_ocaml.Js.to_string el##.id) )

let show s =
  let el = Tyxml_js.To_dom.of_div s in
  el##.style##.display := Js_of_ocaml.Js.string "block" ;
  Js_of_ocaml.Console.console##log
    (Js_of_ocaml.Js.string
       ("Element shown: " ^ Js_of_ocaml.Js.to_string el##.id) )

let submit_button ~id ~class_ ~title ~onclick content =
  button
    ~a:
      [ a_id id
      ; a_class ["btn"; class_]
      ; a_title title
      ; a_onclick onclick
      ; Unsafe.string_attrib "aria-label" title ]
    content

let toolbar ~mobile () =
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
        Problem_dropdown.content ()
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
                ; a_title (I18n.t "codebar_run")
                ; a_onclick (fun _ ->
                      Helpers.add_element_to_app
                        (Modal_view.make "run-modal"
                           (I18n.t "modal_confirm_action")
                           [ txt
                               (I18n.interpolate
                                  (I18n.t "codebar_confirm_run")
                                  [ Helpers.get_local_variable
                                      "yoda-state-last-problem-description"
                                    |> Option.value
                                         ~default:
                                           (Js_of_ocaml.Js.string
                                              "unknown_problem" )
                                    |> Js_of_ocaml.Js.to_string ] ) ]
                           (fun _ -> hide spinner ; false)
                           () ) ;
                      false )
                ; Unsafe.string_attrib "aria-label" "Run" ]
              [terminal_fill_icon (); txt (" " ^ I18n.t "codebar_local_run")]
          ; (* Submit Button *)
            submit_button ~id:"save-all-btn" ~class_:"btn btn-warning mr-2"
              ~title:(I18n.t "codebar_evaluate_save")
              ~onclick:(fun _ ->
                Helpers.add_element_to_app
                  (Modal_view.make "save-all-modal"
                     (I18n.t "modal_confirm_action")
                     [ txt
                         (I18n.interpolate
                            (I18n.t "codebar_confirm_save")
                            [ Helpers.get_local_variable
                                "yoda-state-last-problem-description"
                              |> Option.value
                                   ~default:
                                     (Js_of_ocaml.Js.string "unknown_problem")
                              |> Js_of_ocaml.Js.to_string ] ) ]
                     (fun _ ->
                       hide spinner ;
                       Spinner_modal_update.start () ;
                       false )
                     () ) ;
                false )
              [save_icon (); txt (" " ^ I18n.t "codebar_evaluate")] ]
      ; (* User Profile Section (Optional), add some spacing and align it to
           the far right *)
        div
          ~a:
            [a_class ["user-profile"; "d-flex"; "align-items-center"; "ml-3"]]
            (* Add margin-left for spacing *)
          [span [txt (if not mobile then Helpers.get_username () else "")]]
      ]
  ; (* This is a status bar that can show messages like "All changes saved"
       or "Error saving file" *)
    status_bar ]

let content ~mobile () =
  section
    ~a:[a_class ["panel-section"; "container-fluid"; "py-3"]]
    (toolbar ~mobile ())
