open Js_of_ocaml
open Js_of_ocaml_tyxml
open Tyxml_js.Html
open Lwt.Infix

let content ~contest_id ~problem_row ~tbl () : unit =
  Lwt.async (fun () ->
      Api.Helpers.fetch_json
        (Printf.sprintf "%s/contests/%d/problems" Api.Helpers.base_url
           contest_id )
      >>= fun resp ->
      (* resp is a json string *)
      let resp_json_string = Js.to_string (Json.output resp) in
      Console.console##log (Js.string ("Problems JSON: " ^ resp_json_string)) ;
      let x =
        Api.Openapi.ContestsContestsidProblemsGetResponse2.of_json
          resp_json_string
      in
      List.iter
        (fun (p : Api.Openapi.problem) ->
          Console.console##log (Js.string ("Problem: " ^ p.title)) ;
          let tr_elem = problem_row p.code p.title in
          Dom.appendChild
            (Tyxml_js.To_dom.of_table tbl)
            (Tyxml_js.To_dom.of_tr tr_elem) )
        x ;
      Lwt.return_unit ) ;
  ()
