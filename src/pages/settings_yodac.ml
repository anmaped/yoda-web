open Js_of_ocaml
open Lwt.Infix
open Js_of_ocaml_tyxml
open Tyxml_js.Html

let edit_mode : bool ref = ref false

(* Config tab async state using openapi types *)
let config_json_str : string ref = ref ""

let original_config_json_str : string ref = ref ""

let config_loaded : bool ref = ref false

let config_error : string option ref = ref None

let config_notice : string option ref = ref None

let current_config : Api.Openapi.yodacConfigGetResponse option ref = ref None

let config_history : Api.Openapi.yodacConfigHistoryGetResponse ref = ref []

class type codeMirror = object
  method getValue : Js.js_string Js.t Js.meth

  method setValue : Js.js_string Js.t -> unit Js.meth

  method refresh : unit Js.meth
end

let config_editor : codeMirror Js.t option ref = ref None

let history_loaded : bool ref = ref false

let history_error : string option ref = ref None

let contains_no_change_hint s =
  let normalized = String.lowercase_ascii s in
  Astring.String.is_infix ~affix:"no change" normalized
  || Astring.String.is_infix ~affix:"unchanged" normalized
  || Astring.String.is_infix ~affix:"same config" normalized
  || Astring.String.is_infix ~affix:"already up to date" normalized

let json_has_no_change_hint (json : Yojson.Safe.t) =
  Yojson.Safe.to_string json |> contains_no_change_hint

let config_editor_json (config : Api.Openapi.yodacLanguagesConfig) =
  Api.Openapi.yojson_of_yodacLanguagesConfig config
  |> Yojson.Safe.pretty_to_string

let sync_config_from_editor (editor : codeMirror Js.t) =
  config_json_str := Js.to_string editor##getValue

let current_config_editor_text () =
  match !config_editor with
  | Some editor ->
      sync_config_from_editor editor ;
      !config_json_str
  | None -> (
    match
      Js.Opt.to_option
        (Dom_html.document##getElementById
           (Js.string "config-editor-textarea") )
    with
    | None -> !config_json_str
    | Some element -> (
      match Js.Opt.to_option (Dom_html.CoerceTo.textarea element) with
      | None -> !config_json_str
      | Some textarea -> Js.to_string textarea##.value ) )

let init_config_editor () =
  match
    Js.Opt.to_option
      (Dom_html.document##getElementById
         (Js.string "config-editor-textarea") )
  with
  | None -> config_editor := None
  | Some element -> (
    match Js.Opt.to_option (Dom_html.CoerceTo.textarea element) with
    | None -> config_editor := None
    | Some textarea -> (
      match
        Js.Optdef.to_option (Js.Unsafe.get Js.Unsafe.global "CodeMirror")
      with
      | None -> config_editor := None
      | Some code_mirror ->
          let from_text_area = Js.Unsafe.get code_mirror "fromTextArea" in
          let options =
            object%js
              val lineNumbers = Js._true

              val mode = Js.string "application/json"

              val theme = Js.string (Components.Editor.current_theme ())

              val readOnly = Js.bool (not !edit_mode)

              val indentUnit = 2

              val tabSize = 2

              val matchBrackets = Js._true

              val autoCloseBrackets = Js.bool !edit_mode

              val lineWrapping = Js._true

              val cursorBlinkRate = if !edit_mode then 530 else -1
            end
          in
          let raw_editor =
            Js.Unsafe.fun_call from_text_area
              [|Js.Unsafe.inject textarea; Js.Unsafe.inject options|]
          in
          let editor : codeMirror Js.t = Js.Unsafe.coerce raw_editor in
          config_editor := Some editor ;
          ignore
            (Js.Unsafe.meth_call editor "on"
               [| Js.Unsafe.inject (Js.string "change")
                ; Js.Unsafe.inject
                    (Js.wrap_callback (fun _ _ ->
                         sync_config_from_editor editor ) ) |] ) ;
          editor##setValue (Js.string !config_json_str) ;
          editor##refresh ;
          sync_config_from_editor editor ) )

let schedule_config_editor_setup () =
  ignore
    (Js.Unsafe.fun_call
       (Js.Unsafe.js_expr "window.setTimeout")
       [| Js.Unsafe.inject (Js.wrap_callback init_config_editor)
        ; Js.Unsafe.inject 0 |] )

(* Load / Save config (async) using openapi types *)
let load_config () : unit Lwt.t =
  Api.Helpers.get_config ()
  >>= fun (json, code) ->
  if code = 200 then (
    let json_config = Api.Openapi.yodacConfigGetResponse_of_yojson json in
    current_config := Some json_config ;
    let config_str = config_editor_json json_config.config in
    config_json_str := config_str ;
    original_config_json_str := config_str ;
    config_loaded := true ;
    config_error := None ;
    config_notice := None ;
    Lwt.return () )
  else (
    config_error :=
      Some ("Failed to load config (HTTP " ^ string_of_int code ^ ")") ;
    Lwt.return () )

let save_config () : unit Lwt.t =
  try
    config_error := None ;
    config_notice := None ;
    config_json_str := current_config_editor_text () ;
    let json = Yojson.Safe.from_string !config_json_str in
    let langs =
      match json with
      | `List _ -> Api.Openapi.yodacLanguagesConfig_of_yojson json
      | `Assoc pairs -> (
        match List.assoc_opt "config" pairs with
        | Some cfg -> Api.Openapi.yodacLanguagesConfig_of_yojson cfg
        | None -> failwith "Missing 'config' key in JSON" )
      | _ -> failwith "Expected JSON array or object with 'config' key"
    in
    let req = Api.Openapi.create_yodacConfigPutRequest ~config:langs () in
    Api.Helpers.put_config
      ( Api.Openapi.yojson_of_yodacConfigPutRequest req
      |> Yojson.Safe.to_basic )
    >>= fun (resp_json, code) ->
    if code = 200 || code = 201 then (
      Console.console##log (Js.string "Config saved successfully") ;
      load_config () )
    else if code = 400 && json_has_no_change_hint resp_json then (
      config_error := None ;
      config_notice := Some (I18n.t "config_save_no_changes") ;
      Helpers.trigger_render () ;
      Lwt.return () )
    else (
      config_error :=
        Some ("Failed to save config (HTTP " ^ string_of_int code ^ ")") ;
      config_notice := None ;
      Helpers.trigger_render () ;
      Lwt.return () )
  with
  | Yojson.Json_error e ->
      config_error := Some ("Invalid JSON: " ^ e) ;
      config_notice := None ;
      Helpers.trigger_render () ;
      Lwt.return ()
  | Failure e ->
      config_error := Some e ;
      config_notice := None ;
      Helpers.trigger_render () ;
      Lwt.return ()
  | ex ->
      config_error := Some ("Error: " ^ Printexc.to_string ex) ;
      config_notice := None ;
      Helpers.trigger_render () ;
      Lwt.return ()

let load_history () : unit Lwt.t =
  Api.Helpers.get_config_history ()
  >>= fun (json, code) ->
  if code = 200 then (
    config_history :=
      Api.Openapi.yodacConfigHistoryGetResponse_of_yojson json ;
    history_loaded := true ;
    history_error := None ;
    Lwt.return () )
  else (
    history_error :=
      Some ("Failed to load history (HTTP " ^ string_of_int code ^ ")") ;
    Lwt.return () )

(* Config tab render helpers *)
let lang_table langs =
  let header_row () =
    tr
      ~a:[a_class ["table-light"]]
      [ th [txt "Language"]
      ; th [txt "Ext"]
      ; th [txt "Image"]
      ; th [txt "Tag"]
      ; th [txt "Compile"]
      ; th [txt "Run"] ]
  in
  let data_rows () =
    List.map
      (fun (l : Api.Openapi.yodacLanguageConfig) ->
        tr
          [ td [txt l.language]
          ; td [txt ("." ^ l.ext)]
          ; td [txt l.image]
          ; td [txt l.tag]
          ; td [txt (Option.value (Option.join l.compile) ~default:"—")]
          ; td [txt l.run] ] )
      langs
  in
  table
    ~a:[a_class ["table"; "table-striped"; "table-sm"; "mb-0"]]
    (header_row () :: data_rows ())

(* Render: Config tab *)
let render_config_tab () =
  let meta_div () =
    match !current_config with
    | None -> div []
    | Some c ->
        div
          ~a:[a_class ["mb-2"; "fs-6"]]
          [ p
              ~a:[a_class ["mb-1"; "fw-bold"]]
              [ txt
                  (I18n.interpolate
                     (I18n.t "config_meta_version")
                     [string_of_int c.version] ) ]
          ; p
              ~a:[a_class ["mb-0"]]
              [ txt
                  (I18n.interpolate
                     (I18n.t "config_meta_updated")
                     [c.updated_at] ) ]
          ; p
              ~a:[a_class ["mb-0"]]
              [ txt
                  (I18n.interpolate (I18n.t "config_meta_by") [c.updated_by])
              ] ]
  in
  let config_body () =
    let ta_a =
      [ a_class ["form-control"; "font-monospace"; "fs-6"]
      ; a_rows 25
      ; a_id "config-editor-textarea"
      ; a_wrap `Soft ]
      @ (if !edit_mode then [] else [a_readonly ()])
      @ [ a_oninput (fun ev ->
              let target =
                Js.Opt.get
                  (Dom_html.CoerceTo.textarea
                     (Js.Opt.get ev##.target (fun () -> assert false)) )
                  (fun () -> assert false)
              in
              config_json_str := Js.to_string target##.value ;
              false ) ]
    in
    div
      [ meta_div ()
      ; textarea ~a:ta_a (txt !config_json_str)
      ; div
          ~a:[a_class ["mt-2"; "d-flex"; "gap-2"]]
          [ button
              ~a:
                [ a_class
                    [ "btn"
                    ; ( if !edit_mode then "btn-warning"
                        else "btn-outline-secondary" ) ]
                ; a_onclick (fun _ ->
                      if !edit_mode then (
                        (* When exiting edit mode, restore original config *)
                        config_json_str := !original_config_json_str ;
                        match !config_editor with
                        | Some editor ->
                            editor##setValue
                              (Js.string !original_config_json_str)
                        | None -> () )
                      else
                        (* When entering edit mode, save current content *)
                        config_json_str := current_config_editor_text () ;
                      config_editor := None ;
                      edit_mode := not !edit_mode ;
                      Helpers.trigger_render () ;
                      false ) ]
              [ txt
                  ( if !edit_mode then
                      I18n.interpolate (I18n.t "config_cancel_edit_btn") []
                    else I18n.interpolate (I18n.t "config_edit_btn") [] ) ]
          ; button
              ~a:
                [ a_class
                    ( ["btn"; "btn-primary"]
                    @ if !edit_mode then [] else ["disabled"] )
                ; a_onclick (fun _ ->
                      if !edit_mode then ignore (Lwt.join [save_config ()]) ;
                      false ) ]
              [txt (I18n.t "settings_save_btn")] ]
      ; ( match !config_error with
        | None -> div []
        | Some e -> div ~a:[a_class ["alert"; "alert-danger"; "mt-3"]] [txt e]
        )
      ; ( match !config_notice with
        | None -> div []
        | Some n -> div ~a:[a_class ["alert"; "alert-info"; "mt-3"]] [txt n]
        ) ]
  in
  let history_body () =
    if !history_loaded && !config_history <> [] then
      div
        [ p
            ~a:[a_class ["mb-2"; "fw-bold"]]
            [ txt
                (I18n.interpolate
                   (I18n.t "config_total_entries")
                   [string_of_int (List.length !config_history)] ) ]
        ; table
            ~a:
              [ a_class
                  [ "table"
                  ; "table-striped"
                  ; "table-hover"
                  ; "table-sm"
                  ; "w-100" ] ]
            ( tr
                ~a:[a_class ["table-light"]]
                [ th [txt (I18n.t "config_col_version")]
                ; th [txt (I18n.t "config_col_timestamp")]
                ; th [txt (I18n.t "config_col_changed_by")]
                ; th [txt (I18n.t "config_col_action")]
                ; th [txt (I18n.t "config_col_langs")] ]
            :: List.map
                 (fun (h : Api.Openapi.yodacConfigHistoryEntry) ->
                   tr
                     [ td [txt (string_of_int h.version)]
                     ; td [txt h.timestamp]
                     ; td [txt h.changed_by]
                     ; td [txt h.action]
                     ; td [txt (string_of_int (List.length h.new_config))] ] )
                 !config_history ) ]
    else if !history_error <> None then
      div
        ~a:[a_class ["alert"; "alert-warning"]]
        [ txt
            (Option.value !history_error
               ~default:(I18n.t "config_no_history") ) ]
    else div [p [txt (I18n.t "config_loading_history")]]
  in
  (* async load on first render *)
  Lwt.async (fun () ->
      if (not !config_loaded) || not !history_loaded then (
        load_config ()
        >>= fun () ->
        load_history ()
        >>= fun () -> Helpers.trigger_render () ; Lwt.return () )
      else Lwt.return () ) ;
  let _ = schedule_config_editor_setup () in
  div
    [ Settings_helpers.section_card
        (I18n.t "config_editor_title")
        [config_body ()]
    ; Settings_helpers.section_card
        (I18n.t "config_history_title")
        [history_body ()] ]
