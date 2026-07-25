open Js_of_ocaml
open Js_of_ocaml_tyxml
open Tyxml_js.Html
open Lwt.Infix

let render () =
  let ul = ul [] in
  Lwt.async (fun () ->
      Api.Helpers.get_users ()
      >>= fun (json, status) ->
      if status <> 200 then (
        Console.console##log
          (Js.string (Printf.sprintf "Failed to fetch users: %d" status)) ;
        Lwt.return_unit )
      else
        let users = Api.Openapi.UsersGetResponse2.of_yojson json in
        List.iter
          (fun (u : Api.Openapi.user) ->
            let li =
              li
                [ txt
                    ( u.username ^ " ("
                    ^ Api.Openapi.UserRole.to_json u.role
                    ^ ")" ) ]
            in
            Dom.appendChild
              (Tyxml_js.To_dom.of_ul ul)
              (Tyxml_js.To_dom.of_li li) )
          users ;
        Lwt.return_unit ) ;
  div [ul]
