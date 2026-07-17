open Js_of_ocaml
open Js_of_ocaml_tyxml
open Js_of_ocaml_lwt
open Tyxml_js.Html
open Lwt.Infix

let content ul () =
  Lwt.async (fun () ->
      (* [TODO] convert to Api.Openapi *)
      Api.Helpers.get_contests ()
      >>= fun (json, status) ->
      if status <> 200 then (
        Console.console##log
          (Js.string (Printf.sprintf "Failed to fetch contests: %d" status)) ;
        Lwt.return_unit )
      else
        let contests = Js.to_array json in
        Array.iter
          (fun c ->
            let select_btn =
              a
              (*~a: [ a_href ( Api.Helpers.base_url ^ "/contests/" ^
                Int32.to_string (Js.to_int32 c##.id) ^ "/problems" ) ]*)
                ~a:[a_href "#dashboard"]
                [ txt
                    ( Js.to_string c##.title
                    ^ " ("
                    ^ Js.to_string c##.status
                    ^ ")" ) ]
            in
            let li = li [select_btn] in
            let _ =
              Lwt_js_events.clicks (Tyxml_js.To_dom.of_a select_btn)
                (fun _ _ ->
                  (* print to console *)
                  Console.console##log (Js.string "Clicked!") ;
                  (* set contest ID session *)
                  Helpers.set_current_contest_id
                    (Int32.to_int (Js.to_int32 c##.id)) ;
                  (* set last problem to None *)

                  (* navigate to dashboard page *)

                  (* prevent default action *)
                  Lwt.return_unit )
            in
            Dom.appendChild
              (Tyxml_js.To_dom.of_ul ul)
              (Tyxml_js.To_dom.of_li li) )
          contests ;
        Lwt.return_unit ) ;
  ()
