open Js_of_ocaml
open Js_of_ocaml_tyxml
open Tyxml_js.Html
open I18n
let t = t

(* --- localStorage keys --- *)
let key_theme = "yoda-theme"

let key_font_size = "yoda-font-size"

let key_tab_size = "yoda-tab-size"

let key_line_wrapping = "yoda-line-wrapping"

let key_auto_save = "yoda-auto-save"

(* --- helpers --- *)
let get_theme () =
  match Helpers.get_local_variable key_theme with
  | Some theme -> Js.to_string theme
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

(* --- UI helpers --- *)
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
      let attrs =
        [a_value o] @ if o = current then [a_selected ()] else []
      in
      option ~a:attrs (txt o) )
    opts

(* --- render --- *)
let render () =
  let theme = get_theme () in
  let font_size = get_font_size () in
  let tab_size = get_tab_size () in
  let line_wrapping = get_line_wrapping () in
  let auto_save = get_auto_save () in
  let themes = ["default"; "dark"; "monokai"; "eclipse"] in
  div
    ~a:[a_class ["flex-grow-1"]]
    [ main
        ~a:[a_class ["panel"]]
        [ div
            ~a:[a_class ["container-fluid"; "py-4"]]
            [ h4 ~a:[a_class ["mb-4"]] [txt (t "settings_title")]
            ; section_card "Appearance"
                [ div
                    ~a:[a_class ["mb-3"]]
                    [ label ~a:[a_class ["form-label"]] [txt (t "settings_theme_label")]
                    ; select
                        ~a:[a_id "settings-theme"; a_class ["form-select"]]
                        (select_options themes theme)
                    ; p
                        ~a:[a_class ["form-text"; "text-body-secondary"]]
                        [txt (t "settings_theme_desc")] ]
                ; div
                    ~a:[a_class ["mb-3"]]
                    [ label ~a:[a_class ["form-label"]] [txt (t "settings_font_size_label")]
                    ; input
                        ~a:
                          [ a_input_type `Range
                          ; a_class ["form-range"]
                          ; a_input_min (`Number 10)
                          ; a_input_max (`Number 24)
                          ; a_step (Some 1.)
                          ; a_value (string_of_int font_size)
                          ; a_id "settings-font-size" ]
                        ()
                    ; p
                        ~a:[a_class ["form-text"; "text-body-secondary"]]
                        [txt (t "settings_font_size_desc")] ] ]
            ; section_card "Editor"
                [ div
                    ~a:[a_class ["mb-3"]]
                    [ label ~a:[a_class ["form-label"]] [txt (t "settings_tab_size_label")]
                    ; select
                        ~a:[a_id "settings-tab-size"; a_class ["form-select"]]
                        (select_options ["2"; "4"; "8"]
                           (string_of_int tab_size) )
                    ; p
                        ~a:[a_class ["form-text"; "text-body-secondary"]]
                        [txt (t "settings_tab_size_desc")] ]
                ; toggle_switch ~checked:line_wrapping
                    ~label_text:"Line Wrapping" ~on_change:set_line_wrapping
                    ()
                ; p
                    ~a:[a_class ["form-text"; "text-body-secondary"]]
                    [txt (t "settings_wrap_lines")] ]
            ; section_card "Behavior"
                [ toggle_switch ~checked:auto_save ~label_text:"Auto-save"
                    ~on_change:set_auto_save ()
                ; p
                    ~a:[a_class ["form-text"; "text-body-secondary"]]
                    [txt (t "settings_auto_save")] ]
            ; div
                ~a:[a_class ["d-flex"; "gap-2"; "mt-4"]]
                [ button
                    ~a:
                      [ a_class ["btn"; "btn-primary"]
                      ; a_onclick (fun _ ->
                            let sel =
                              Dom_html.getElementById "settings-theme"
                            in
                            let input_el =
                              Js.Opt.get
                                (Dom_html.CoerceTo.input sel)
                                (fun _ -> assert false)
                            in
                            let v = Js.to_string input_el##.value in
                            set_theme v ;
                            Console.console##log
                              (Js.string ("Theme saved: " ^ v)) ;
                            false ) ]
                    [txt (t "settings_save_btn")]
                ; button
                    ~a:
                      [ a_class ["btn"; "btn-secondary"]
                      ; a_onclick (fun _ ->
                            set_theme "default" ;
                            set_font_size 14 ;
                            set_tab_size 2 ;
                            set_line_wrapping true ;
                            set_auto_save false ;
                            Console.console##log (Js.string "Settings reset") ;
                            false ) ]
                    [txt (t "settings_reset_btn")] ] ] ] ]
