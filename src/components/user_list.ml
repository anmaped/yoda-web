open Js_of_ocaml
open Js_of_ocaml_tyxml
open Tyxml_js.Html
open Lwt.Infix

let render () =
  let ul = ul [] in
  Lwt.async (fun () ->
    Api.get_users () >>= fun json ->
    let users = Js.to_array json in
    Array.iter (fun u ->
      let li = li [txt (Js.to_string u##.username ^ " (" ^ Js.to_string u##.role ^ ")")] in
      Dom.appendChild (Tyxml_js.To_dom.of_ul ul) (Tyxml_js.To_dom.of_li li)
    ) users;
    Lwt.return_unit
  );
  div [ul]