open Js_of_ocaml
open Js_of_ocaml_tyxml
open Tyxml_js.Html


let textarea_or_create ~root_id ~textarea_id =
  let root = Helpers.get_element_by_id root_id in
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
      Dom.appendChild root ta ;
      ta

(* Minimal type for CodeMirror instance *)
class type codeMirror = object
  method getValue : Js.js_string Js.t Js.meth

  method setValue : Js.js_string Js.t -> unit Js.meth

  method refresh : unit Js.meth
end

let init () =
  let textarea =
    textarea_or_create ~root_id:"codeboard" ~textarea_id:"codeboard-editor"
  in
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

      val theme = Js.string "default"

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
  (* Optional: set initial content explicitly *)
  editor##refresh ;
  editor##setValue (Js.string "(* Start coding here *)\n") ;
  editor

let content () =
  section
    ~a:
      [ a_class ["panel-section"; "container-fluid"; "py-1"]
      ; a_style "height: 100%; min-height: 0;" ]
    [ div
        ~a:
          [ a_class ["contest-card"; "rounded"; "p-1"; "shadow-sm"]
          ; a_style "height: 100%; min-height: 0;" ]
        [div ~a:[a_id "codeboard"; a_style "height: 100%; min-height: 0;"] []] ]
