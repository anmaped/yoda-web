open Js_of_ocaml_tyxml
open Tyxml_js.Html

let render () =
  let content =
    div
      ~a:[a_class ["flex-grow-1"]; a_style "height: 100%;"]
      [ main
          ~a:
            [ a_class ["d-flex"; "flex-column"; "panel"]
            ; a_style "height: 100%;" ]
          [ Components.Codebar.content ()
          ; Components.Testbar.content ()
          ; Components.Tabbar.content ()
          ; Components.Editor.content () ] ]
  in
  let content_ =
    div
      ~a:[a_class ["flex-grow-1"]; a_style "height: 100%;"]
      [ main
          ~a:
            [ a_class ["d-flex"; "flex-column"; "panel"]
            ; a_style "height: 100%;" ]
          [ Components.Codebar.content ()
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
  (* save editor state and testbar state using a auto-save mechanism *)
  let () =
    let open Lwt.Infix in
    (* load all state before starting the auto-save loop *)
    Components.Editor.load_state () ;
    Components.Testbar.load_state () ;
    let rec save_state_loop () =
      Components.Codebar.show Components.Codebar.spinner ;
      Components.Codebar.update_status_bar ~no_time:true "Saving..." ;
      Components.Editor.save_state () ;
      Lwt.return_unit
      >>= fun () ->
      Components.Testbar.save_state () ;
      Lwt.return_unit
      >>= fun () ->
      Js_of_ocaml_lwt.Lwt_js.sleep 1.0
      >>= fun () ->
      Components.Codebar.update_status_bar "All changes saved" ;
      Components.Codebar.hide Components.Codebar.spinner ;
      Js_of_ocaml_lwt.Lwt_js.sleep 60.0 >>= fun () -> save_state_loop ()
    in
    Lwt.async save_state_loop
  in
  if Helpers.is_mobile () then [content]
  else if Helpers.is_wide_desktop () then
    [Components.Sidebar.sidebar (); content_]
  else [Components.Sidebar.sidebar (); content]
