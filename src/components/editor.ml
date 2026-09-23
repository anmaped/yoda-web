open Js_of_ocaml
open Js_of_ocaml_tyxml
open Tyxml_js.Html

let codeboard =
  div
    ~a:
      [ a_id "codeboard"
      ; a_style "height: 100%; min-height: 0; min-width: 0; overflow: hidden;" ]
    []

let settings_theme = ref ""

let on_change : (unit -> unit) ref = ref (fun () -> ())

let set_on_change callback = on_change := callback

let current_theme () =
  match String.lowercase_ascii (String.trim !settings_theme) with
  | "dark" | "onedark" -> "material-darker"
  | "monokai" -> "monokai"
  | "eclipse" -> "eclipse"
  | "nord" -> "nord"
  | _ -> "default"

let current_codemirror_theme_class () = "cm-s-" ^ current_theme ()

let textarea_or_create ~textarea_id =
  match
    Js.Opt.to_option
      (Dom_html.document##getElementById (Js.string textarea_id))
  with
  | Some el -> (
    match Js.Opt.to_option (Dom_html.CoerceTo.textarea el) with
    | Some ta -> ta
    | None -> failwith ("#" ^ textarea_id ^ " is not a <textarea>") )
  | None ->
      let ta = Dom_html.createTextarea Dom_html.document in
      ta##.id := Js.string textarea_id ;
      ta##.value := Js.string "(* Start coding here *)\n" ;
      Dom.appendChild (Tyxml_js.To_dom.of_div codeboard) ta ;
      ta

(* Minimal type for CodeMirror instance *)
class type codeMirror = object
  method getValue : Js.js_string Js.t Js.meth

  method setValue : Js.js_string Js.t -> unit Js.meth

  method refresh : unit Js.meth
end

let auto_save_enabled = ref false

let set_auto_save enabled = auto_save_enabled := enabled

let is_auto_save_enabled () = !auto_save_enabled

let editor =
  let textarea = textarea_or_create ~textarea_id:"codeboard-editor" in
  (* Ensure CodeMirror is loaded *)
  let code_mirror =
    match
      Js.Optdef.to_option (Js.Unsafe.get Js.Unsafe.global "CodeMirror")
    with
    | None -> failwith "CodeMirror not loaded"
    | Some cm -> cm
  in
  let from_text_area = Js.Unsafe.get code_mirror "fromTextArea" in
  (* Improved options *)
  let options =
    object%js
      val lineNumbers = Js._true

      val mode = Js.string "mllike"

      val theme = Js.string (current_theme ())

       val indentUnit = 2

      val tabSize = 2

      val matchBrackets = Js._true

      val autoCloseBrackets = Js._true

       val lineWrapping = Js._true
    end
  in
  (* Create editor and keep reference *)
  let raw_editor =
    Js.Unsafe.fun_call from_text_area
      [|Js.Unsafe.inject textarea; Js.Unsafe.inject options|]
  in
  let editor : codeMirror Js.t = Js.Unsafe.coerce raw_editor in
  ignore
    (Js.Unsafe.meth_call editor "on"
       [| Js.Unsafe.inject (Js.string "change")
        ; Js.Unsafe.inject
            (Js.wrap_callback (fun _editor _change ->
              (** Trigger the change callback *)
                 (!on_change) () )) |]) ;
  (* Optional: set initial content explicitly *)
  editor##refresh ;
  editor##setValue (Js.string "(* Start coding here *)\n") ;
  editor

let set_option name value =
  ignore
    (Js.Unsafe.meth_call editor "setOption"
       [| Js.Unsafe.inject (Js.string name); Js.Unsafe.inject value |])

let set_font_size size =
  let style = string_of_int size ^ "px" in
  match Js.Opt.to_option (Dom_html.document##querySelector (Js.string ".CodeMirror")) with
  | Some element -> element##.style##.fontSize := Js.string style
  | None -> ()

let set_tab_size size =
  set_option "tabSize" (Js.Unsafe.inject size) ;
  set_option "indentUnit" (Js.Unsafe.inject size)

let set_line_wrapping enabled =
  set_option "lineWrapping" (Js.Unsafe.inject (Js.bool enabled)) ;
  editor##refresh

let apply_settings font_size tab_size line_wrapping =
  set_font_size font_size ;
  set_tab_size tab_size ;
  set_line_wrapping line_wrapping

let set_theme t =
  settings_theme := t ;
  let theme = current_theme () in
  ignore
    (Js.Unsafe.meth_call editor "setOption"
       [| Js.Unsafe.inject (Js.string "theme")
        ; Js.Unsafe.inject (Js.string theme) |] )

let load_state () = ()

let save_state () = ()

let content () =
  section
    ~a:
       [ a_class ["panel-section"; "container-fluid"; "py-1"]
       ; a_style "height: 100%; min-height: 0; min-width: 0; overflow: hidden;" ]
    [ div
        ~a:
           [ a_class ["contest-card"; "rounded"; "p-1"; "shadow-sm"]
           ; a_style "height: 100%; min-height: 0; min-width: 0; overflow: hidden;" ]
         [codeboard] ]
