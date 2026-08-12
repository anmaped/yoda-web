open Js_of_ocaml_tyxml
open Tyxml_js.Html

(* save editor state and testbar state using a auto-save mechanism *)
let () =
  let open Lwt.Infix in
  (* load all state before starting the auto-save loop *)
  Components.Editor.load_state () ;
  Components.Testbar.load_state () ;
  let rec save_state_loop () =
    Components.Codebar.show Components.Codebar.spinner ;
    Components.Codebar.update_status_bar ~no_time:true
      (I18n.t "codebar_saving") ;
    Components.Editor.save_state () ;
    Lwt.return_unit
    >>= fun () ->
    Components.Testbar.save_state () ;
    Lwt.return_unit
    >>= fun () ->
    Js_of_ocaml_lwt.Lwt_js.sleep 1.0
    >>= fun () ->
    Components.Codebar.update_status_bar (I18n.t "codebar_all_changes_saved") ;
    Components.Codebar.hide Components.Codebar.spinner ;
    Js_of_ocaml_lwt.Lwt_js.sleep 60.0 >>= fun () -> save_state_loop ()
  in
  Lwt.async save_state_loop

let render () =
  let content_short ~mobile =
    div
      ~a:[a_class ["flex-grow-1"]; a_style "height: 100%;"]
      [ main
          ~a:
            [ a_class ["d-flex"; "flex-column"; "panel"]
            ; a_style "height: 100%;" ]
          [ Components.Codebar.content ~mobile ()
          ; Components.Testbar.content ()
          ; Components.Tabbar.content ()
          ; Components.Editor.content () ] ]
  in
  let content_wide =
    div
      ~a:[a_class ["flex-grow-1"]; a_style "height: 100%;"]
      [ main
          ~a:
            [ a_class ["d-flex"; "flex-column"; "panel"]
            ; a_style "height: 100%;" ]
          [ Components.Codebar.content ~mobile:false ()
          ; div
              ~a:
                [ a_class ["d-flex"; "flex-grow-1"]
                ; a_style "height: 100%; min-height: 0;" ]
              [ (* LEFT: tabbar + editor *)
                div
                  ~a:[a_class ["flex-grow-1"; "d-flex"; "flex-column"]]
                  [Components.Tabbar.content (); Components.Editor.content ()]
              ; (* RIGHT: testbar (only spans tabbar + editor) *)
                aside
                  ~a:
                    [ a_style
                        "width: 30%; border-left: 1px solid #ddd; \
                         background: #f8f9fa; height: 100%; overflow-y: \
                         auto;" ]
                  [Components.Testbar.content ~sidebyside:false ()] ] ] ]
  in
  match Helpers.layout () with
  | Helpers.Mobile ->
      [ div
          [ Components.Sidebar.sidebar ~mobile:true ()
          ; content_short ~mobile:true ] ]
  | Helpers.Normal ->
      [Components.Sidebar.sidebar ~wide:false (); content_short ~mobile:false]
  | Helpers.Wide -> [Components.Sidebar.sidebar (); content_wide]
