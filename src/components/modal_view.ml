open Js_of_ocaml_tyxml
open Tyxml_js.Html

let make name title content action () =
  div
    ~a:[a_id name]
    [ (* backdrop *)
      div ~a:[a_class ["modal-backdrop"; "fade"; "show"]] []
    ; (* modal *)
      div
        ~a:[a_class ["modal"; "fade"; "show"]; a_style "display:block;"]
        [ div
            ~a:[a_class ["modal-dialog"]]
            [ div
                ~a:[a_class ["modal-content"]]
                [ div
                    ~a:[a_class ["modal-header"]]
                    [ h5 ~a:[a_class ["modal-title"]] [txt title]
                    ; button
                        ~a:
                          [ a_class ["btn-close"]
                          ; a_onclick (fun _ ->
                                Helpers.remove_first_element_from_app
                                  ("#" ^ name) ;
                                false ) ]
                        [] ]
                ; div ~a:[a_class ["modal-body"]] content
                ; div
                    ~a:[a_class ["modal-footer"]]
                    [ button
                        ~a:
                          [ a_class ["btn"; "btn-secondary"]
                          ; a_onclick (fun _ ->
                                Helpers.remove_first_element_from_app
                                  ("#" ^ name) ;
                                false ) ]
                        [txt (I18n.t "modal_cancel")]
                    ; button
                        ~a:
                          [ a_class ["btn"; "btn-primary"]
                          ; a_onclick (fun _ ->
                                Helpers.remove_first_element_from_app
                                  ("#" ^ name) ;
                                action () ) ]
                        [txt (I18n.t "modal_confirm")] ] ] ] ] ]
