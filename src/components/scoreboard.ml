open Js_of_ocaml
open Js_of_ocaml_tyxml
open Tyxml_js.Html
open Lwt.Infix

let render ~contest_id () =
  let table = table [] in
  Lwt.async (fun () ->
    Api.get_scoreboard contest_id >>= fun entries ->
    Array.iter (fun e ->
      let row =
        tr [td [txt (Js.to_string e##.team)];
            td [txt (Int32.to_string (Js.to_int32 e##.solved))];
            td [txt (Int32.to_string (Js.to_int32 e##.penalty))]] in
      Dom.appendChild (Tyxml_js.To_dom.of_table table) (Tyxml_js.To_dom.of_tr row)
    ) entries;
    Lwt.return_unit
  );
  div [table]