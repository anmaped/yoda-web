open Js_of_ocaml
open Js_of_ocaml_tyxml
open Js_of_ocaml_lwt
open Tyxml_js.Html
open Lwt.Infix

let content ul () =
  Lwt.async (fun () ->
      Api.Helpers.get_contests ()
      >>= fun (json, status) ->
      if status <> 200 then (
        Console.console##log
          (Js.string (Printf.sprintf "Failed to fetch contests: %d" status)) ;
        Lwt.return_unit )
      else
        let contests = Api.Openapi.ContestsGetResponse2.of_yojson json in
        List.iter
          (fun (c : Api.Openapi.contest) ->
            let contest_id = string_of_int c.id in
            let is_current =
              try Helpers.get_current_contest_id () = c.id with _ -> false
            in
            let status = Api.Openapi.ContestStatus.to_json c.status in
            let select_btn =
              a
                ~a:
                  [ a_href "#dashboard"
                  ; a_class
                      [ "contest-list-item"
                      ; ( if is_current then "contest-list-item-current"
                          else "" ) ]
                  ; a_title (I18n.t "problems_select_contest") ]
                [ div
                    ~a:[a_class ["contest-list-item-content"]]
                    [ div
                        ~a:[a_class ["contest-list-item-title"]]
                        [txt c.title]
                    ; div
                        ~a:[a_class ["contest-list-item-meta"]]
                        [ span
                            ~a:[a_class ["contest-list-item-id"]]
                            [txt ("#" ^ contest_id)]
                        ; span
                            ~a:
                              [ a_class
                                  [ "badge"
                                  ; "contest-list-item-status"
                                  ; ( if is_current then "bg-primary"
                                      else "bg-secondary" ) ] ]
                            [txt status] ] ]
                ; span ~a:[a_class ["contest-list-item-arrow"]] [txt "→"] ]
            in
            let li = li ~a:[a_class ["contest-list-row"]] [select_btn] in
            let _ =
              Lwt_js_events.clicks (Tyxml_js.To_dom.of_a select_btn)
                (fun _ _ ->
                  (* set contest ID session *)
                  Helpers.set_current_contest_id c.id ;
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
