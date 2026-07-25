open Js_of_ocaml
open Lwt.Infix
open Js_of_ocaml_tyxml
open Tyxml_js.Html

(* localStorage keys *)
let key_theme = "yoda-settings-theme"

let key_font_size = "yoda-settings-font-size"

let key_tab_size = "yoda-settings-tab-size"

let key_line_wrapping = "yoda-settings-line-wrapping"

let key_auto_save = "yoda-settings-auto-save"

let key_settings_referrer = "yoda-settings-referrer"

let key_language = "yoda-language"

(* Tab state *)
type tab = Settings | Config

let tab_label = function Settings -> "General" | Config -> "YodaC"

let active_tab : tab ref = ref Settings

let edit_mode : bool ref = ref false

(* Local helpers *)
let get_theme () =
  match Helpers.get_local_variable key_theme with
  | Some t -> Js.to_string t
  | None -> "light"

let get_font_size () =
  match Helpers.get_local_variable key_font_size with
  | Some s -> ( try int_of_string (Js.to_string s) with _ -> 14 )
  | None -> 14

let get_tab_size () =
  match Helpers.get_local_variable key_tab_size with
  | Some s -> ( try int_of_string (Js.to_string s) with _ -> 2 )
  | None -> 2

let get_line_wrapping () =
  match Helpers.get_local_variable key_line_wrapping with
  | Some v -> Js.to_string v = "true"
  | None -> true

let get_auto_save () =
  match Helpers.get_local_variable key_auto_save with
  | Some v -> Js.to_string v = "true"
  | None -> false

let set_theme t = Helpers.set_local_variable key_theme t

let set_font_size n =
  Helpers.set_local_variable key_font_size (string_of_int n)

let set_tab_size n =
  Helpers.set_local_variable key_tab_size (string_of_int n)

let set_line_wrapping b =
  Helpers.set_local_variable key_line_wrapping (string_of_bool b)

let set_auto_save b =
  Helpers.set_local_variable key_auto_save (string_of_bool b)

let get_lang () =
  match Helpers.get_local_variable key_language with
  | Some v -> Js.to_string v
  | None -> "en"

let set_lang code =
  let lang =
    match code with
    | "fr" -> I18n.FR
    | "es" -> I18n.ES
    | "pt" -> I18n.PT
    | "ar" -> I18n.AR
    | _ -> I18n.EN
  in
  I18n.set_language lang ; Helpers.trigger_render ()

(** Apply a theme to the UI *)
let apply_theme t =
  let body = Dom_html.document##.body in
  (* Bootstrap base theme *)
  let bs_theme =
    match t with "dark" | "monokai" | "eclipse" -> "dark" | _ -> "light"
  in
  body##setAttribute (Js.string "data-bs-theme") (Js.string bs_theme) ;
  (* Remove any previous custom theme classes *)
  body##.classList##remove (Js.string "theme-dark") ;
  body##.classList##remove (Js.string "theme-monokai") ;
  body##.classList##remove (Js.string "theme-eclipse") ;
  (* Add the selected theme class *)
  begin match t with
  | "dark" -> ignore (body##.classList##add (Js.string "theme-dark"))
  | "monokai" -> ignore (body##.classList##add (Js.string "theme-monokai"))
  | "eclipse" -> ignore (body##.classList##add (Js.string "theme-eclipse"))
  | _ -> ()
  end ;
  (* Persist theme *)
  set_theme t ;
  (* Re-render *)
  Helpers.trigger_render ()

(* Apply saved theme on page load *)
let _ = apply_theme (get_theme ())

(* Settings referrer helper *)
let save_referrer () =
  match Dom_html.window##.location##.hash |> Js.to_string with
  (* start with prefix #settings *)
  | h when not (Astring.String.is_prefix ~affix:"#settings" h) ->
      Helpers.set_local_variable key_settings_referrer h
  | _ -> ()

let close_settings () =
  match Helpers.get_local_variable key_settings_referrer with
  | Some r ->
      if Js.to_string r <> "" then Helpers.navigate_to (Js.to_string r)
  | None -> Helpers.navigate_to "#dashboard"

(* UI helpers *)
let section_card title content =
  div
    ~a:[a_class ["card"; "mb-3"]]
    [ div
        ~a:[a_class ["card-header"]]
        [h6 ~a:[a_class ["card-title"; "mb-0"]] [txt title]]
    ; div ~a:[a_class ["card-body"]] content ]

let toggle_switch ~checked ~label_text ~on_change () =
  let attrs =
    [ a_input_type `Checkbox
    ; a_class ["form-check-input"]
    ; a_id ("toggle-" ^ label_text)
    ; a_onchange (fun ev ->
          let target =
            Js.Opt.get
              (Dom_html.CoerceTo.input
                 (Js.Opt.get ev##.target (fun () -> assert false)) )
              (fun () -> assert false)
          in
          on_change (Js.to_bool target##.checked) ;
          false ) ]
    @ if checked then [a_checked ()] else []
  in
  div
    ~a:[a_class ["d-flex"; "justify-content-between"; "align-items-center"]]
    [ label [txt label_text]
    ; div
        ~a:[a_class ["form-check"; "form-switch"]]
        [ input ~a:attrs ()
        ; label
            ~a:
              [ a_class ["form-check-label"]
              ; a_label_for ("toggle-" ^ label_text) ]
            [] ] ]

let select_options opts current =
  List.map
    (fun o ->
      option
        ~a:([a_value o] @ if o = current then [a_selected ()] else [])
        (txt o) )
    opts

(* Config tab async state using openapi types *)
let config_json_str : string ref = ref ""

let config_loaded : bool ref = ref false

let config_error : string option ref = ref None

let current_config : Api.Openapi.yodacConfigGetResponse option ref = ref None

let config_history : Api.Openapi.yodacConfigHistoryGetResponse ref = ref []

let history_loaded : bool ref = ref false

let history_error : string option ref = ref None

(* Load / Save config (async) using openapi types *)
let load_config () : unit Lwt.t =
  Api.Helpers.get_config ()
  >>= fun (json, code) ->
  if code = 200 then (
    current_config :=
      Some (Api.Openapi.yodacConfigGetResponse_of_yojson json) ;
    config_json_str := Yojson.Safe.to_string json ;
    config_loaded := true ;
    config_error := None ;
    Lwt.return () )
  else (
    config_error :=
      Some ("Failed to load config (HTTP " ^ string_of_int code ^ ")") ;
    Lwt.return () )

let save_config () : unit Lwt.t =
  try
    let json = Yojson.Safe.from_string !config_json_str in
    match json with
    | `Assoc pairs -> (
      match List.assoc_opt "config" pairs with
      | Some cfg ->
          let langs = Api.Openapi.yodacLanguagesConfig_of_yojson cfg in
          let req =
            Api.Openapi.create_yodacConfigPutRequest ~config:langs ()
          in
          Api.Helpers.put_config
            ( Api.Openapi.yojson_of_yodacConfigPutRequest req
            |> Yojson.Safe.to_basic )
          >>= fun (_j, code) ->
          if code = 200 || code = 201 then (
            Console.console##log (Js.string "Config saved successfully") ;
            load_config () )
          else (
            config_error :=
              Some ("Failed to save config (HTTP " ^ string_of_int code ^ ")") ;
            Lwt.return () )
      | None ->
          config_error := Some "Missing 'config' key in JSON" ;
          Lwt.return () )
    | _ ->
        config_error := Some "Expected JSON object with 'config' key" ;
        Lwt.return ()
  with
  | Yojson.Json_error e ->
      config_error := Some ("Invalid JSON: " ^ e) ;
      Lwt.return ()
  | ex ->
      config_error := Some ("Error: " ^ Printexc.to_string ex) ;
      Lwt.return ()

let load_history () : unit Lwt.t =
  Api.Helpers.get_config_history ()
  >>= fun (json, code) ->
  if code = 200 then (
    config_history :=
      Api.Openapi.yodacConfigHistoryGetResponse_of_yojson json ;
    history_loaded := true ;
    history_error := None ;
    Helpers.trigger_resize () ;
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

(* Render: Settings tab *)
let render_settings_tab () =
  let theme = get_theme ()
  and font_size = get_font_size ()
  and tab_size = get_tab_size ()
  and line_wrap = get_line_wrapping ()
  and auto_save = get_auto_save () in
  let themes = ["default"; "dark"; "monokai"; "eclipse"] in
  let lang = get_lang () in
  let languages =
    List.map
      (fun (l, name) ->
        let code =
          match l with
          | I18n.EN -> "en"
          | I18n.FR -> "fr"
          | I18n.ES -> "es"
          | I18n.PT -> "pt"
          | I18n.AR -> "ar"
        in
        (code, name) )
      I18n.languages
  in
  div
    [ section_card "Appearance"
        [ div
            ~a:[a_class ["mb-3"]]
            [ label ~a:[a_class ["form-label"]] [txt "Language"]
            ; select
                ~a:
                  [ a_id "settings-language"
                  ; a_class ["form-select"]
                  ; a_onchange (fun ev ->
                        let target =
                          Js.Opt.get
                            (Dom_html.CoerceTo.select
                               (Js.Opt.get ev##.target (fun () ->
                                    assert false ) ) )
                            (fun () -> assert false)
                        in
                        set_lang (Js.to_string target##.value) ;
                        false ) ]
                (List.map
                   (fun (code, name) ->
                     option
                       ~a:
                         ( [a_value code]
                         @ if code = lang then [a_selected ()] else [] )
                       (txt name) )
                   languages ) ]
        ; div
            ~a:[a_class ["mb-3"]]
            [ label
                ~a:[a_class ["form-label"]]
                [txt (I18n.t "settings_theme_label")]
            ; select
                ~a:
                  [ a_id "settings-theme"
                  ; a_class ["form-select"]
                  ; a_onchange (fun ev ->
                        let target =
                          Js.Opt.get
                            (Dom_html.CoerceTo.select
                               (Js.Opt.get ev##.target (fun () ->
                                    assert false ) ) )
                            (fun () -> assert false)
                        in
                        let value = Js.to_string target##.value in
                        set_theme value ; false ) ]
                (select_options themes theme) ]
        ; div
            ~a:[a_class ["mb-3"]]
            [ label
                ~a:[a_class ["form-label"]]
                [txt (I18n.t "settings_font_size_label")]
            ; input
                ~a:
                  [ a_input_type `Range
                  ; a_class ["form-range"]
                  ; a_input_min (`Number 10)
                  ; a_input_max (`Number 42)
                  ; a_step (Some 1.)
                  ; a_value (string_of_int font_size)
                  ; a_id "settings-font-size"
                  ; a_onchange (fun ev ->
                        let target =
                          Js.Opt.get
                            (Dom_html.CoerceTo.input
                               (Js.Opt.get ev##.target (fun () ->
                                    assert false ) ) )
                            (fun () -> assert false)
                        in
                        let value = Js.to_string target##.value in
                        set_font_size (int_of_string value) ;
                        Helpers.trigger_render () ;
                        false ) ]
                ()
            ; div
                ~a:
                  [ a_class ["text-center"; "mt-1"]
                  ; a_style ("font-size:" ^ string_of_int font_size ^ "px")
                  ]
                [txt "The quick brown fox — sample text"] ] ]
    ; section_card "Editor"
        [ div
            ~a:[a_class ["mb-3"]]
            [ label
                ~a:[a_class ["form-label"]]
                [txt (I18n.t "settings_tab_size_label")]
            ; select
                ~a:
                  [ a_id "settings-tab-size"
                  ; a_class ["form-select"]
                  ; a_onchange (fun ev ->
                        let target =
                          Js.Opt.get
                            (Dom_html.CoerceTo.select
                               (Js.Opt.get ev##.target (fun () ->
                                    assert false ) ) )
                            (fun () -> assert false)
                        in
                        let value = Js.to_string target##.value in
                        set_tab_size (int_of_string value) ;
                        Helpers.trigger_render () ;
                        false ) ]
                (select_options ["2"; "4"; "8"] (string_of_int tab_size)) ]
        ; toggle_switch ~checked:line_wrap ~label_text:"Line Wrapping"
            ~on_change:set_line_wrapping () ]
    ; section_card "Behavior"
        [ toggle_switch ~checked:auto_save ~label_text:"Auto-save"
            ~on_change:set_auto_save () ]
    ; div
        ~a:[a_class ["d-flex"; "gap-2"; "mt-4"]]
        [ button
            ~a:
              [ a_class ["btn"; "btn-secondary"]
              ; a_onclick (fun _ ->
                    set_lang "en" ;
                    set_theme "default" ;
                    set_font_size 14 ;
                    set_tab_size 2 ;
                    set_line_wrapping true ;
                    set_auto_save true ;
                    Helpers.trigger_render () ;
                    false ) ]
            [txt (I18n.t "settings_reset_btn")] ] ]

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
              [txt ("Version: " ^ string_of_int c.version)]
          ; p ~a:[a_class ["mb-0"]] [txt ("Updated: " ^ c.updated_at)]
          ; p ~a:[a_class ["mb-0"]] [txt ("By: " ^ c.updated_by)] ]
  in
  let config_body () =
    let ta_a =
      [ a_class ["form-control"; "font-monospace"; "fs-6"]
      ; a_rows 25
      ; a_id "config-editor-textarea"
      ; a_wrap `Soft ]
      @ if !edit_mode then [] else [a_readonly ()]
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
                      edit_mode := not !edit_mode ;
                      Helpers.trigger_render () ;
                      false ) ]
              [txt (if !edit_mode then "Cancel Edit" else "Edit")]
          ; button
              ~a:
                [ a_class ["btn"; "btn-primary"]
                ; a_onclick (fun _ ->
                      ignore (Lwt.join [save_config ()]) ;
                      Helpers.trigger_render () ;
                      false ) ]
              [txt (I18n.t "settings_save_btn")] ]
      ; ( match !config_error with
        | None -> div []
        | Some e -> div ~a:[a_class ["alert"; "alert-danger"; "mt-3"]] [txt e]
        ) ]
  in
  let history_body () =
    if !history_loaded && !config_history <> [] then
      div
        [ p
            ~a:[a_class ["mb-2"; "fw-bold"]]
            [ txt
                ( "Total entries: "
                ^ string_of_int (List.length !config_history) ) ]
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
                [ th [txt "Version"]
                ; th [txt "Timestamp"]
                ; th [txt "Changed By"]
                ; th [txt "Action"]
                ; th [txt "Langs"] ]
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
        [txt (Option.value !history_error ~default:"No history")]
    else div [p [txt "Loading history..."]]
  in
  (* async load on first render *)
  let _ =
    if not !config_loaded then ignore (Lwt.join [load_config ()]) else ()
  in
  let _ =
    if not !history_loaded then ignore (Lwt.join [load_history ()]) else ()
  in
  div
    [ section_card "Config Editor" [config_body ()]
    ; section_card "Configuration History" [history_body ()] ]

(* Render: tabs bar *)
let render_tabs () =
  div
    ~a:[a_class ["mb-4"]]
    [ button
        ~a:
          [ a_class
              [ "btn"
              ; ( if !active_tab = Settings then "btn-primary"
                  else "btn-outline-primary" ) ]
          ; a_onclick (fun _ ->
                Helpers.navigate_to "#settings" ;
                false ) ]
        [txt (tab_label Settings)]
    ; button
        ~a:
          [ a_class
              [ "btn"
              ; ( if !active_tab = Config then "btn-primary"
                  else "btn-outline-primary" ) ]
          ; a_onclick (fun _ ->
                Helpers.navigate_to "#settings-yodac" ;
                false ) ]
        [txt (tab_label Config)] ]

(* render *)
let render ?(tab = "general") () =
  div
    ~a:[a_class ["flex-grow-1"]]
    [ main
        ~a:[a_class ["panel"]]
        [ div
            ~a:[a_class ["container-fluid"; "py-4"]]
            [ div
                ~a:
                  [ a_class
                      [ "d-flex"
                      ; "justify-content-between"
                      ; "align-items-center"
                      ; "mb-4" ] ]
                [ h4 ~a:[a_class ["mb-0"]] [txt (I18n.t "settings_title")]
                ; button
                    ~a:
                      [ a_class ["btn"; "btn-outline-secondary"]
                      ; a_onclick (fun _ -> close_settings () ; false) ]
                    [i ~a:[a_class ["bi"; "bi-x-lg"]] []] ]
            ; render_tabs ()
            ; ( match tab with
              | "general" ->
                  active_tab := Settings ;
                  render_settings_tab ()
              | "yodac" ->
                  active_tab := Config ;
                  render_config_tab ()
              | _ -> failwith "Invalid tab" ) ] ] ]
