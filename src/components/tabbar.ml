open Js_of_ocaml_tyxml
open Tyxml_js.Html

let on_tab_click tab_id _ev =
  ignore
    (Js_of_ocaml.Js.Unsafe.fun_call
       (Js_of_ocaml.Js.Unsafe.js_expr "switchTab")
       [|Js_of_ocaml.Js.Unsafe.inject (Js_of_ocaml.Js.string tab_id)|] ) ;
  true

let actions_bar =
  div
    ~a:[a_class ["d-flex"; "justify-content-between"; "align-items-center"]]
    [ div
        ~a:
          [ a_class ["btn-group"]
          ; a_role ["group"]
          ; a_aria "label" ["Code actions"] ]
        [ button
            ~a:
              [ a_id "download-zip-btn"
              ; a_class ["btn"; "btn-outline-secondary"; "btn-sm"]
              ; a_title "Download all files as ZIP" ]
            [Icons.download_icon (); txt ""]
        ; button
            ~a:
              [ a_id "copy-all-btn"
              ; a_class ["btn"; "btn-outline-secondary"; "btn-sm"]
              ; a_title "Copy all code to clipboard" ]
            [Icons.clipboard_icon (); txt (I18n.t "tabbar_copy")]
        ; button
            ~a:
              [ a_id "add-file-btn"
              ; a_class ["btn"; "btn-outline-primary"; "btn-sm"]
              ; a_title "Set Skeleton"
              ; a_onclick (fun _ ->
                    Helpers.add_element_to_app
                      (Modal_view.make "run-modal"
                         (I18n.t "modal_confirm_action")
                         [txt (I18n.t "tabbar_confirm_skeleton")]
                         (fun _ -> false)
                         () ) ;
                    false ) ]
            [Icons.arrow_clockwise_icon (); txt (I18n.t "tabbar_skeleton")] ] ]

let content () =
  section
    ~a:[a_class ["panel-section"; "container-fluid"; "py-1"]]
    [ div
        ~a:
          [ a_class
              ["contest-card"; "rounded"; "shadow-sm"; "align-items-center"]
          ]
        [ div
            ~a:[a_id "tab-bar"]
            [ div
                ~a:
                  [ a_class ["tab"; "active"]
                  ; a_user_data "tab" "tab0"
                  ; a_onclick (on_tab_click "0") ]
                [txt "file1.ml"]
            ; div
                ~a:
                  [ a_class ["tab"]
                  ; a_user_data "tab" "tab1"
                  ; a_onclick (on_tab_click "1") ]
                [txt "file2.ml"]
            ; div
                ~a:
                  [ a_class ["tab"]
                  ; a_user_data "tab" "tab2"
                  ; a_onclick (on_tab_click "2") ]
                [txt "file3.ml"] ]
        ; actions_bar ] ]
