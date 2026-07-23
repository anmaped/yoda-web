open Js_of_ocaml
open Js_of_ocaml_tyxml
open Js_of_ocaml_lwt
open Tyxml_js.Html
open Lwt.Infix
open I18n
let t = t

let render ~contest_id ~problem_id () =
  let lang_input = input ~a:[a_placeholder (t "subform_label_language")] () in
  let code_input = textarea ~a:[a_placeholder (t "subform_placeholder_source")] (txt "") in
  let submit_btn = button [txt (t "subform_submit")] in
  let div_form = div [
    div [txt (t "subform_label_language"); lang_input];
    div [txt (t "subform_label_source"); code_input];
    submit_btn
  ] in

  let _ =
    Lwt_js_events.clicks (Tyxml_js.To_dom.of_button submit_btn) (fun _ _ ->
      let lang = Js.to_string (Tyxml_js.To_dom.of_input lang_input)##.value in
      let code = Js.to_string (Tyxml_js.To_dom.of_textarea code_input)##.value in
      Api.Helpers.submit_solution contest_id problem_id lang code >>= fun _resp ->
      Console.console##log (Js.string "Submitted!");
      Lwt.return_unit
    )
  in
  div_form