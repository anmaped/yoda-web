open Js_of_ocaml
open Js_of_ocaml_tyxml
open Tyxml_js.Html
open Lwt.Infix

let render ~contest_id:() =
  let ul = ul [] in
  Lwt.async (fun () ->
    Api.get_contests () >>= fun contests ->
    Array.iter (fun c ->
      let li_item =
        li [a ~a:[a_href ("/contests/" ^ Int32.to_string (Js.to_int32 c##.id) ^ "/problems")]
              [txt (Js.to_string c##.title ^ " (" ^ Js.to_string c##.status ^ ")")]] in
      Dom.appendChild (Tyxml_js.To_dom.of_ul ul)  (Tyxml_js.To_dom.of_li li_item)
    ) contests;
    Lwt.return_unit
  );
  div [ul]