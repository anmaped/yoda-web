open Js_of_ocaml_tyxml
open Tyxml_js.Html
open Lwt.Infix

let on_tab_click tab_id _ev =
  ignore
    (Js_of_ocaml.Js.Unsafe.fun_call
       (Js_of_ocaml.Js.Unsafe.js_expr "switchTab")
       [|Js_of_ocaml.Js.Unsafe.inject (Js_of_ocaml.Js.string tab_id)|] ) ;
  true

let tab_div = div ~a:[a_id "tab-bar"] []

let create_tab ~filename ~active ~tab_id =
  div
    ~a:
      [ a_class (if active then ["tab"; "active"] else ["tab"])
      ; a_user_data "tab" tab_id
      ; a_onclick (on_tab_click tab_id) ]
    [txt filename]

let create_tabs_from_artifacts artifacts =
  match artifacts with
  | [] -> []
  | _ ->
      let tabs =
        List.mapi
          (fun i (artifact : Api.Openapi.SourceArtifact.t) ->
            let tab_id = "tab" ^ string_of_int i in
            create_tab ~filename:artifact.filename ~active:(i = 0) ~tab_id )
          artifacts
      in
      tabs

let update_tab_div_dom ?(artifacts = []) () =
  let tabs =
    if List.length artifacts > 0 then create_tabs_from_artifacts artifacts
    else
      [ (* Fallback to hardcoded tabs *)
        create_tab ~filename:"fallback.ml" ~active:true ~tab_id:"tab0" ]
  in
  let tab_div_el = Tyxml_js.To_dom.of_div tab_div in
  (* Clear existing children *)
  while Js_of_ocaml.Js.Opt.test tab_div_el##.firstChild do
    let first_child =
      Js_of_ocaml.Js.Opt.get tab_div_el##.firstChild (fun () -> assert false)
    in
    Js_of_ocaml.Dom.removeChild tab_div_el first_child
  done ;
  (* Append new tabs *)
  List.iter
    (fun tab ->
      Js_of_ocaml.Dom.appendChild tab_div_el (Tyxml_js.To_dom.of_div tab) )
    tabs

let update pid () =
  Lwt.async (fun () ->
      Api.Helpers.get_problem pid
      >>= fun (resp, status) ->
      if status <> 200 then (
        Js_of_ocaml.Console.console##log
          (Js_of_ocaml.Js.string (Printf.sprintf "Failed to fetch problem: %d" status)) ;
        Lwt.return_unit )
      else
        let problem = Api.Openapi.Problem.of_yojson resp in
        let artifacts = problem.source_artifacts in
        let artifacts = Option.value ~default:[] artifacts in
        update_tab_div_dom ~artifacts () ;
        Lwt.return_unit )

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
            [Icons.arrow_clockwise_icon (); txt (I18n.t "tabbar_skeleton")]
        ] ]

let content () =
  section
    ~a:[a_class ["panel-section"; "container-fluid"; "py-1"]]
    [ div
        ~a:
          [ a_class
              ["contest-card"; "rounded"; "shadow-sm"; "align-items-center"]
          ]
        [tab_div; actions_bar] ]
