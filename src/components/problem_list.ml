open Js_of_ocaml
open Js_of_ocaml_tyxml
open Lwt.Infix

let content ~contest_id ~problem_row ~tbody () : unit =
  Lwt.async (fun () ->
      Api.Helpers.get_problems contest_id
      >>= fun (resp, status) ->
      if status <> 200 then (
        Console.console##log
          (Js.string (Printf.sprintf "Failed to fetch problems: %d" status)) ;
        Lwt.return_unit )
      else
        (* resp is a json string *)
        let problems =
          Api.Openapi.ContestsContestsidProblemsGetResponse2.of_yojson resp
        in
        List.iter
          (fun (p : Api.Openapi.problem) ->
            let tr_elem = problem_row p.code p.title in
            Dom.appendChild tbody (Tyxml_js.To_dom.of_tr tr_elem) )
          problems ;
        Lwt.return_unit ) ;
  ()
