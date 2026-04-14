open Js_of_ocaml
open Js_of_ocaml_tyxml
open Tyxml_js.Html
open Lwt.Infix

let render ~contest_id ~problem_id () =
  let ul = ul [] in
  Lwt.async (fun () ->
    Api.get_problems contest_id >>= fun problems ->
    Array.iter (fun p ->
      let li_item = li [txt (Js.to_string p##.title)] in
      Dom.appendChild (Tyxml_js.To_dom.of_ul ul) (Tyxml_js.To_dom.of_li li_item)
    ) problems;
    Lwt.return_unit
  );
  div [ul]