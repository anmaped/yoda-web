open Js_of_ocaml
open Js_of_ocaml_tyxml
open Tyxml_js.Html

let spinner = div []

let status_p_tyxml = p [txt (I18n.t "spinner_modal_ready")]

let status_p_dom = Tyxml_js.To_dom.of_p status_p_tyxml

let history_items_tyxml = ul ~a:[a_class ["list-group"; "list-group-flush"]] []

let history_items_dom = Tyxml_js.To_dom.of_ul history_items_tyxml

let history_messages : string list ref = ref []

let status_h5_tyxml =
  h5 ~a:[a_class ["modal-title"]] [txt (I18n.t "spinner_modal_processing")]

let status_h5_dom = Tyxml_js.To_dom.of_h5 status_h5_tyxml

let clear_history_dom () =
  while Js.Opt.test history_items_dom##.firstChild do
    let first_child =
      Js.Opt.get history_items_dom##.firstChild (fun () -> assert false)
    in
    Dom.removeChild history_items_dom first_child
  done

let render_history () =
  clear_history_dom () ;
  List.iter
    (fun message ->
      let item =
        li ~a:[a_class ["list-group-item"; "small"]] [txt message]
      in
      Dom.appendChild history_items_dom (Tyxml_js.To_dom.of_li item) )
    (List.rev !history_messages)

let reset_status () =
  history_messages := [] ;
  status_p_dom##.textContent := Js.some (Js.string (I18n.t "spinner_modal_ready")) ;
  status_h5_dom##.textContent :=
    Js.some (Js.string (I18n.t "spinner_modal_processing")) ;
  render_history ()

let add_history_message msg =
  match !history_messages with
  | last :: _ when last = msg -> ()
  | _ ->
      history_messages := msg :: !history_messages ;
      render_history ()

let remove () =
  reset_status () ;
  let spinner_dom = Tyxml_js.To_dom.of_element spinner in
  Js.Opt.iter spinner_dom##.parentNode (fun parent ->
      ignore (parent##removeChild (spinner_dom :> Dom.node Js.t)) )

let make () =
  reset_status () ;
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
                        [ img ~src:Blobs.yoda_cameling_gif_url
                            ~alt:(I18n.t "spinner_modal_processing")
                            ~a:
                              [ a_class
                                  ["img-fluid"; "d-block"; "mx-auto"; "mb-3"]
                              ; a_style "max-width: 240px;" ]
                            ()
                        ; status_p_tyxml
                        ; div
                            ~a:[a_class ["mt-3"; "text-start"]]
                            [ h6 ~a:[a_class ["text-muted"]] [txt "History"]
                            ; div
                                ~a:
                                  [ a_class ["border"; "rounded"; "bg-light"]
                                  ; a_style
                                      "max-height: 180px; overflow-y: auto;" ]
                                [history_items_tyxml] ]
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
let update_text msg =
  status_p_dom##.textContent := Js.some (Js.string msg) ;
  add_history_message msg

let update_title msg = status_h5_dom##.textContent := Js.some (Js.string msg)
