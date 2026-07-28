open Js_of_ocaml
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
type tab = Settings | Config | Stats | Users

let tab_label = function
  | Settings -> I18n.t "settings_tab_general"
  | Config -> I18n.t "settings_tab_yodac"
  | Stats -> I18n.t "settings_tab_stats"
  | Users -> I18n.t "settings_tab_users"

let active_tab : tab ref = ref Settings

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
    match t with "dark" | "monokai" | "nord" | "onedark" -> "dark" | _ -> "light"
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
  | "nord" -> ignore (body##.classList##add (Js.string "theme-nord"))
  | "onedark" -> ignore (body##.classList##add (Js.string "theme-onedark"))
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

(* Render: Settings tab *)
let render_settings_tab () =
  let theme = get_theme ()
  and font_size = get_font_size ()
  and tab_size = get_tab_size ()
  and line_wrap = get_line_wrapping ()
  and auto_save = get_auto_save () in
  let themes = ["default"; "dark"; "monokai"; "eclipse"; "nord"; "onedark"] in
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
    [ Settings_helpers.section_card
        (I18n.t "settings_appearance_title")
        [ div
            ~a:[a_class ["mb-3"]]
            [ label
                ~a:[a_class ["form-label"]]
                [txt (I18n.t "settings_language_label")]
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
                (Settings_helpers.select_options themes theme) ]
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
    ; Settings_helpers.section_card
        (I18n.t "settings_editor_title")
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
                (Settings_helpers.select_options ["2"; "4"; "8"]
                   (string_of_int tab_size) ) ]
        ; Settings_helpers.toggle_switch ~checked:line_wrap
            ~label_text:
              (I18n.interpolate (I18n.t "settings_line_wrap_label") [])
            ~on_change:set_line_wrapping () ]
    ; Settings_helpers.section_card
        (I18n.t "settings_behavior_title")
        [ Settings_helpers.toggle_switch ~checked:auto_save
            ~label_text:
              (I18n.interpolate (I18n.t "settings_auto_save_label") [])
            ~on_change:set_auto_save () ]
    ; div
        ~a:[a_class ["d-flex"; "gap-2"; "mt-4"]]
        [ button
            ~a:
              [ a_class ["btn"; "btn-secondary"]
              ; a_onclick (fun _ ->
                    set_lang "en" ;
                    set_theme "eclipse" ;
                    set_font_size 14 ;
                    set_tab_size 2 ;
                    set_line_wrapping true ;
                    set_auto_save true ;
                    Helpers.trigger_render () ;
                    false ) ]
            [txt (I18n.t "settings_reset_btn")] ] ]

(* Render: tabs bar *)
let render_tabs () =
  div
    ~a:[a_class ["mb-4"]]
    [ ul
        ~a:[a_class ["nav"; "nav-tabs"]]
        [ li
            ~a:[a_class ["nav-item"]]
            [ a
                ~a:
                  [ a_class
                      ( "nav-link"
                      :: (if !active_tab = Settings then ["active"] else [])
                      )
                  ; a_href "#settings"
                  ; a_onclick (fun _ ->
                        Helpers.navigate_to "#settings" ;
                        false ) ]
                [txt (tab_label Settings)] ]
        ; ( if Helpers.is_admin () then
              li
                ~a:[a_class ["nav-item"]]
                [ a
                    ~a:
                      [ a_class
                          ( "nav-link"
                          :: (if !active_tab = Stats then ["active"] else [])
                          )
                      ; a_href "#settings-stats"
                      ; a_onclick (fun _ ->
                            Helpers.navigate_to "#settings-stats" ;
                            false ) ]
                    [txt (tab_label Stats)] ]
            else
              li
                ~a:[a_class ["nav-item"; "disabled"]]
                [a ~a:[a_class ["nav-link disabled"]] [txt (tab_label Stats)]]
          )
        ; ( if Helpers.is_admin () then
              li
                ~a:[a_class ["nav-item"]]
                [ a
                    ~a:
                      [ a_class
                          ( "nav-link"
                          :: (if !active_tab = Config then ["active"] else [])
                          )
                      ; a_href "#settings-yodac"
                      ; a_onclick (fun _ ->
                            Helpers.navigate_to "#settings-yodac" ;
                            false ) ]
                    [txt (tab_label Config)] ]
            else
              li
                ~a:[a_class ["nav-item"; "disabled"]]
                [ a
                    ~a:[a_class ["nav-link disabled"]]
                    [txt (tab_label Config)] ] )
        ; ( if Helpers.is_admin () then
              li
                ~a:[a_class ["nav-item"]]
                [ a
                    ~a:
                      [ a_class
                          ( "nav-link"
                          :: (if !active_tab = Users then ["active"] else [])
                          )
                      ; a_href "#settings-users"
                      ; a_onclick (fun _ ->
                            Helpers.navigate_to "#settings-users" ;
                            false ) ]
                    [txt (tab_label Users)] ]
            else
              li
                ~a:[a_class ["nav-item"; "disabled"]]
                [a ~a:[a_class ["nav-link disabled"]] [txt (tab_label Users)]]
          ) ] ]

(* render *)
let render ?(tab = "general") () =
  let admin_badge =
    if Helpers.is_admin () then
      span
        ~a:[a_class ["badge"; "bg-success"; "ms-2"; "align-self-center"]]
        [ i ~a:[a_class ["bi"; "bi-shield-lock"]] []
        ; txt (I18n.t "settings_admin_badge") ]
    else
      (* no badge *)
      span []
  in
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
                ; admin_badge
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
                  Settings_yodac.render_config_tab ()
              | "stats" ->
                  active_tab := Stats ;
                  Settings_stats.render_stats_tab ()
              | "users" ->
                  active_tab := Users ;
                  Settings_user.render_users_tab ()
              | _ -> failwith "Invalid tab" ) ] ] ]
