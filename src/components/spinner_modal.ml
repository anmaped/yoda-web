open Js_of_ocaml_tyxml
open Tyxml_js.Html

let make () =
  div
    [ (* backdrop *)
      div ~a:[a_class ["modal-backdrop"; "fade"; "show"]] []
    ; (* fullscreen modal *)
      div
        ~a:[a_class ["modal"; "fade"; "show"]; a_style "display:block;"]
        [ div
            ~a:[a_class ["modal-dialog"; "modal-fullscreen"]]
            [ div
                ~a:[a_class ["modal-content"]]
                [ (* header *)
                  div
                    ~a:[a_class ["modal-header"]]
                    [ h5
                        ~a:[a_class ["modal-title"]]
                        [txt (I18n.t "codebar_processing")]
                    ; button
                        ~a:[a_class ["btn-close"]; a_onclick (fun _ -> false)]
                        [] ]
                ; (* body *)
                  div
                    ~a:[a_class ["modal-body"]]
                    [ div
                        [ txt (I18n.t "codebar_ready")
                        ; br ()
                        ; button
                            ~a:
                              [ a_class ["btn"; "btn-primary"; "mt-3"]
                              ; a_onclick (fun _ -> false) ]
                            [txt (I18n.t "codebar_start")] ] ] ] ] ] ]
