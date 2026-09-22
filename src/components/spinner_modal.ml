open Js_of_ocaml
open Js_of_ocaml_tyxml
open Tyxml_js.Html

let spinner = div []

let status_p_tyxml = p [txt "..."]

let status_p_dom = Tyxml_js.To_dom.of_p status_p_tyxml

let history_items_tyxml =
  ul ~a:[a_class ["list-group"; "list-group-flush"]] []

let history_items_dom = Tyxml_js.To_dom.of_ul history_items_tyxml

type status_entry = {message: string; kind: string; show_in_history: bool}

let status_entries : status_entry list ref = ref []

let status_h5_tyxml = h5 ~a:[a_class ["modal-title"]] [txt "..."]

let status_h5_dom = Tyxml_js.To_dom.of_h5 status_h5_tyxml

let default_status () = I18n.t "spinner_modal_ready"

(* "error" "success" "warning" "info" *)
let default_status_kind = "info"

let current_status_entry () =
  match !status_entries with
  | entry :: _ -> entry
  | [] ->
      { message= default_status ()
      ; kind= default_status_kind
      ; show_in_history= false }

let render_current_status () =
  let {message; kind; _} = current_status_entry () in
  status_p_dom##.textContent := Js.some (Js.string message) ;
  status_p_dom##.className :=
    Js.string
      (String.concat " "
         ["spinner-modal-status"; "spinner-modal-status-" ^ kind] )

let clear_history_dom () =
  while Js.Opt.test history_items_dom##.firstChild do
    let first_child =
      Js.Opt.get history_items_dom##.firstChild (fun () -> assert false)
    in
    Dom.removeChild history_items_dom first_child
  done

let render_history () =
  clear_history_dom () ;
  let history_entries =
    match !status_entries with _current :: rest -> rest | [] -> []
  in
  List.iter
    (fun entry ->
      let item =
        li
          ~a:
            [ a_class
                [ "list-group-item"
                ; "small"
                ; "spinner-modal-history-item"
                ; "spinner-modal-history-item-" ^ entry.kind ] ]
          [txt entry.message]
      in
      Dom.appendChild history_items_dom (Tyxml_js.To_dom.of_li item) )
    ( history_entries
    |> List.filter (fun entry -> entry.show_in_history)
    |> List.rev )

let render_status_views () = render_current_status () ; render_history ()

let reset_status () =
  status_entries := [] ;
  status_h5_dom##.textContent
  := Js.some (Js.string (I18n.t "spinner_modal_processing")) ;
  render_status_views ()

let set_status ?kind ?(history = true) msg =
  let kind = Option.value kind ~default:default_status_kind in
  match !status_entries with
  | {message; kind= current_kind; show_in_history} :: _
    when message = msg && show_in_history = history && kind = current_kind ->
      ()
  | _ ->
      status_entries :=
        {message= msg; kind; show_in_history= history} :: !status_entries ;
      render_status_views ()

let update_current_status ?kind msg = set_status ?kind ~history:false msg

let update_history_status ?kind msg = set_status ?kind ~history:true msg

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
                                      "max-height: 180px; overflow-y: auto;"
                                  ]
                                [history_items_tyxml] ]
                        ; br ()
                        ; button
                            ~a:
                              [ a_class ["btn"; "btn-primary"; "mt-3"]
                              ; a_onclick (fun _ -> remove () ; false) ]
                            [txt (I18n.t "modal_close")] ] ] ] ] ] ]
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
let update_text ?kind msg = update_history_status ?kind msg

let update_title msg = status_h5_dom##.textContent := Js.some (Js.string msg)
