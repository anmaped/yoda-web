open Js_of_ocaml
open Js_of_ocaml_tyxml
open Tyxml_js.Html

let yoda_cameling_gif = [%blob "../../static/yoda-cameling-loop.gif"]

let yoda_cameling_gif_url =
  let byte_values =
    Array.init (String.length yoda_cameling_gif) (fun i ->
        Char.code yoda_cameling_gif.[i] )
  in
  let uint8 =
    new%js Typed_array.uint8Array_fromArray (Js.array byte_values)
  in
  let blob =
    File.blob_from_any ~contentType:"image/gif"
      [`arrayBufferView (uint8 :> Typed_array.arrayBufferView Js.t)]
  in
  Js.to_string (Dom_html.window##._URL##createObjectURL blob)

let spinner = div []

let status_p_tyxml = p [txt (I18n.t "spinner_modal_ready")]

let status_p_dom = Tyxml_js.To_dom.of_p status_p_tyxml

let status_h5_tyxml =
  h5 ~a:[a_class ["modal-title"]] [txt (I18n.t "spinner_modal_processing")]

let status_h5_dom = Tyxml_js.To_dom.of_h5 status_h5_tyxml

let remove () =
  let spinner_dom = Tyxml_js.To_dom.of_element spinner in
  Js.Opt.iter spinner_dom##.parentNode (fun parent ->
      ignore (parent##removeChild (spinner_dom :> Dom.node Js.t)) )

let make () =
  let modal_backdrop =
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
                    [ status_h5_tyxml
                    ; button
                        ~a:
                          [ a_class ["btn-close"]
                          ; a_onclick (fun _ -> remove () ; false) ]
                        [] ]
                ; (* body *)
                  div
                    ~a:[a_class ["modal-body"]]
                    [ div
                        [ img ~src:yoda_cameling_gif_url
                            ~alt:(I18n.t "spinner_modal_processing")
                            ~a:
                              [ a_class
                                  ["img-fluid"; "d-block"; "mx-auto"; "mb-3"]
                              ; a_style "max-width: 240px;" ]
                            ()
                        ; status_p_tyxml
                        ; br ()
                        ; button
                            ~a:
                              [ a_class ["btn"; "btn-primary"; "mt-3"]
                              ; a_onclick (fun _ -> remove () ; false) ]
                            [txt (I18n.t "spinner_model_close")] ] ] ] ] ] ]
  in
  (* add modal_backdrop to spinner via dom*)
  List.iter
    (fun p ->
      Dom.appendChild
        (Tyxml_js.To_dom.of_div spinner)
        (Tyxml_js.To_dom.of_div p) )
    modal_backdrop ;
  spinner

(** [update_text msg] mutates the modal text node.
    Returns unit silently if the node has not been captured yet. *)
let update_text msg = status_p_dom##.textContent := Js.some (Js.string msg)

let update_title msg = status_h5_dom##.textContent := Js.some (Js.string msg)
