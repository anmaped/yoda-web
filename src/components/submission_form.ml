open Js_of_ocaml
open Js_of_ocaml_tyxml
open Js_of_ocaml_lwt
open Tyxml_js.Html
open Lwt.Infix

let render ~contest_id ~problem_id () =
  let lang_input = input ~a:[a_placeholder "Language"] () in
  let code_input = textarea ~a:[a_placeholder "Source code"] (txt "") in
  let submit_btn = button [txt "Submit"] in
  let div_form = div [
    div [txt "Language:"; lang_input];
    div [txt "Source code:"; code_input];
    submit_btn
  ] in

  let _ =
    Lwt_js_events.clicks (Tyxml_js.To_dom.of_button submit_btn) (fun _ _ ->
      let lang = Js.to_string (Tyxml_js.To_dom.of_input lang_input)##.value in
      let code = Js.to_string (Tyxml_js.To_dom.of_textarea code_input)##.value in
      Api.submit_solution contest_id problem_id lang code >>= fun _resp ->
      Console.console##log (Js.string "Submitted!");
      Lwt.return_unit
    )
  in
  div_form