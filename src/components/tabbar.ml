open Js_of_ocaml_tyxml
open Tyxml_js.Html
open Lwt.Infix

type file_state = {filename: string; mutable content: string}

let key_state_editor_files = "yoda-state-editor-files"

let key_state_editor_active_file = "yoda-state-editor-active-file"

let current_problem_id : int option ref = ref None

let current_active_tab : int ref = ref 0

let current_files : file_state list ref = ref []

let current_languages : Api.Openapi.languages ref = ref []

let storage_key_for_problem pid =
  Printf.sprintf "%s-%d" key_state_editor_files pid

let active_tab_key_for_problem pid =
  Printf.sprintf "%s-%d" key_state_editor_active_file pid

let get_editor_content () = Js_of_ocaml.Js.to_string Editor.editor##getValue

let set_editor_content content =
  Editor.editor##setValue (Js_of_ocaml.Js.string content) ;
  Editor.editor##refresh

let deserialize_problem_files raw =
  try
    let json = Yojson.Basic.from_string raw in
    match json with
    | `Assoc fields ->
        List.filter_map
          (fun (filename, value) ->
            match value with
            | `String content -> Some (filename, content)
            | _ -> None )
          fields
    | _ -> []
  with _ -> []

let serialize_problem_files files =
  `Assoc
    (List.map
       (fun (file_state : file_state) ->
         (file_state.filename, `String file_state.content) )
       files )
  |> Yojson.Basic.to_string

let get_saved_files_for_problem pid =
  match Helpers.get_local_variable (storage_key_for_problem pid) with
  | None -> []
  | Some raw -> deserialize_problem_files (Js_of_ocaml.Js.to_string raw)

let get_saved_active_file_for_problem pid =
  match Helpers.get_local_variable (active_tab_key_for_problem pid) with
  | Some value -> Some (Js_of_ocaml.Js.to_string value)
  | None -> None

let persist_current_state () =
  match !current_problem_id with
  | None -> ()
  | Some pid ->
      let payload = serialize_problem_files !current_files in
      Helpers.set_local_variable (storage_key_for_problem pid) payload ;
      let active_file =
        match List.nth_opt !current_files !current_active_tab with
        | Some file -> file.filename
        | None -> ""
      in
      Helpers.set_local_variable (active_tab_key_for_problem pid) active_file

let save_active_editor_content () =
  match List.nth_opt !current_files !current_active_tab with
  | None -> ()
  | Some file ->
      file.content <- get_editor_content () ;
      persist_current_state ()

let load_editor_from_active_tab () =
  match List.nth_opt !current_files !current_active_tab with
  | None -> set_editor_content ""
  | Some file -> set_editor_content file.content

let select_tab idx =
  if idx >= 0 && idx < List.length !current_files then (
    save_active_editor_content () ;
    current_active_tab := idx ;
    load_editor_from_active_tab () ;
    persist_current_state () )

let tab_div = div ~a:[a_id "tab-bar"] []

let rec on_tab_click idx _ev = select_tab idx ; update_tab_div_dom () ; false

and create_tab ~filename ~active ~tab_id ~tab_index =
  div
    ~a:
      [ a_class (if active then ["tab"; "active"] else ["tab"])
      ; a_user_data "tab" tab_id
      ; a_onclick (on_tab_click tab_index) ]
    [txt filename]

and create_tabs_from_files files =
  List.mapi
    (fun i (file : file_state) ->
      let tab_id = "tab" ^ string_of_int i in
      create_tab ~filename:file.filename ~active:(i = !current_active_tab)
        ~tab_id ~tab_index:i )
    files

and update_tab_div_dom () =
  let tabs =
    if List.length !current_files > 0 then
      create_tabs_from_files !current_files
    else
      [ (* Fallback to hardcoded tabs *)
        create_tab ~filename:"fallback.ml" ~active:true ~tab_id:"tab0"
          ~tab_index:0 ]
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

let init_files_for_problem pid artifacts =
  let persisted = get_saved_files_for_problem pid in
  let persisted_tbl = Hashtbl.create (max 8 (List.length persisted)) in
  List.iter
    (fun (filename, content) ->
      Hashtbl.replace persisted_tbl filename content )
    persisted ;
  let files =
    match artifacts with
    | [] -> [{filename= "fallback.ml"; content= "(* Start coding here *)\n"}]
    | _ ->
        List.map
          (fun (artifact : Api.Openapi.SourceArtifact.t) ->
            let content =
              match Hashtbl.find_opt persisted_tbl artifact.filename with
              | Some saved -> saved
              | None -> artifact.content
            in
            {filename= artifact.filename; content} )
          artifacts
  in
  let active_idx =
    match get_saved_active_file_for_problem pid with
    | None -> 0
    | Some filename ->
        let rec find_idx idx = function
          | [] -> 0
          | file :: rest ->
              if file.filename = filename then idx
              else find_idx (idx + 1) rest
        in
        find_idx 0 files
  in
  current_problem_id := Some pid ;
  current_files := files ;
  current_active_tab := active_idx ;
  load_editor_from_active_tab () ;
  persist_current_state () ;
  update_tab_div_dom ()

let get_current_source_artifacts () =
  save_active_editor_content () ;
  List.map
    (fun (file : file_state) ->
      Api.Openapi.SourceArtifact.create ~filename:file.filename
        ~content:file.content () )
    !current_files

let get_current_languages () = !current_languages

let update pid () =
  Lwt.async (fun () ->
      save_active_editor_content () ;
      Api.Helpers.get_problem pid
      >>= fun (resp, status) ->
      if status <> 200 then (
        Js_of_ocaml.Console.console##log
          (Js_of_ocaml.Js.string
             (Printf.sprintf "Failed to fetch problem: %d" status) ) ;
        Lwt.return_unit )
      else
        let problem = Api.Openapi.Problem.of_yojson resp in
        current_languages := problem.languages ;
        let artifacts = problem.source_artifacts in
        let artifacts = Option.value ~default:[] artifacts in
        init_files_for_problem pid artifacts ;
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
