open Js_of_ocaml
open Js_of_ocaml_tyxml
open Lwt.Infix


let render () =
  let open Tyxml_js.Html in
  let ul = ul [] in

  Lwt.async (fun () ->
    Api.get_contests () >>= fun json ->
    let contests = Js.to_array json in
    Array.iter (fun c ->
      let li =
        li [a ~a:[a_href ("/contests/" ^ Int32.to_string (Js.to_int32 c##.id) ^ "/problems")] 
              [txt (Js.to_string c##.title ^ " (" ^ Js.to_string c##.status ^ ")")]] 
      in
      Dom.appendChild (Tyxml_js.To_dom.of_ul ul) (Tyxml_js.To_dom.of_li li)
    ) contests;
    Lwt.return_unit
  );

  div [h2 [txt "Contests"]; ul]