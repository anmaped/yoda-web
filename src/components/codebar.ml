open Js_of_ocaml_tyxml
open Tyxml_js.Html

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
              [ Icons.terminal_fill_icon ()
              ; txt (" " ^ I18n.t "codebar_local_run") ]
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
              [Icons.save_icon (); txt (" " ^ I18n.t "codebar_evaluate")] ]
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
