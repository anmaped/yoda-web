open Js_of_ocaml
open Js_of_ocaml_tyxml
open Tyxml_js.Html
open Lwt.Infix

let render ~contest_id () =
  let table = table [] in
  Lwt.async (fun () ->
      Api.Helpers.get_scoreboard contest_id
      >>= fun (entries, _status) ->
      let entries =
        Api.Openapi.ContestsIdScoreboardGetResponse2.of_yojson entries
      in
      List.iter
        (fun (e : Api.Openapi.scoreboardEntry) ->
          let row =
            tr
              [ td [txt e.team]
              ; td [txt (string_of_int e.solved)]
              ; td [txt (string_of_int e.penalty)] ]
          in
          Dom.appendChild
            (Tyxml_js.To_dom.of_table table)
            (Tyxml_js.To_dom.of_tr row) )
        entries ;
      Lwt.return_unit ) ;
  div [table]
