open Js_of_ocaml
open Js_of_ocaml_tyxml
open Tyxml_js.Html
open Lwt.Infix

let content () =
  let sel =
    select
      ~a:[a_id "problem-select"; a_class ["form-select"; "w-auto"]]
      [option ~a:[a_value ""] (txt (I18n.t "dropdown_select_problem"))]
  in
  let fetch_and_populate () =
    let contest_id = Helpers.get_current_contest_id () in
    Lwt.async (fun () ->
        Api.Helpers.get_problems contest_id
        >>= fun (resp, status) ->
        if status <> 200 then (
          Console.console##log
            (Js.string
               (Printf.sprintf "Failed to fetch problems: %d" status) ) ;
          Lwt.return_unit )
        else
          let problems =
            Api.Openapi.ContestsContestsidProblemsGetResponse2.of_yojson resp
          in
          (* Replace the select's children with our options *)
          let dom_sel = Tyxml_js.To_dom.of_select sel in
          (* Clear existing options *)
          (* Remove all options *)
          while dom_sel##.length > 0 do
            dom_sel##remove 0
          done ;
          (* Add option *)
          let add_option value label =
            let opt = Dom_html.createOption Dom_html.document in
            opt##.value := Js.string value ;
            Dom.appendChild opt
              (Dom_html.document##createTextNode (Js.string label)) ;
            Dom.appendChild dom_sel opt
          in
          (* Add default option *)
          add_option "" "-- Select a problem --" ;
          (* Build option elements *)
          (* Add problem options *)
          List.iter
            (fun (p : Api.Openapi.problem) ->
              add_option p.code (p.code ^ ": " ^ p.title) )
            problems ;
          (* Set last problem as selected if none is selected or invalid *)
          let select_problem code =
            let options = dom_sel##.options in
            let rec find_and_select idx =
              if idx >= options##.length then ()
              else
                match Js.Opt.to_option (options##item idx) with
                | Some opt ->
                    if Js.to_string opt##.value = code then
                      opt##.selected := Js._true
                    else find_and_select (idx + 1)
                | None -> find_and_select (idx + 1)
            in
            find_and_select 0
          in
          let _ =
            match
              Helpers.get_local_variable "yoda-state-last-problem-id"
            with
            | Some code -> select_problem (Js.to_string code)
            | None -> (
              match List.rev problems with
              | last_problem :: _ ->
                  Helpers.set_local_variable "yoda-state-last-problem-id"
                    last_problem.code ;
                  Helpers.set_local_variable
                    "yoda-state-last-problem-description"
                    (last_problem.code ^ ": " ^ last_problem.title) ;
                  select_problem last_problem.code
              | [] -> () )
          in
          (* Add change handler *)
          ignore
            (Dom_html.addEventListener dom_sel Dom_html.Event.change
               (Dom_html.handler (fun _ ->
                    let idx = dom_sel##.selectedIndex in
                    if idx <= 0 then Js._false
                    else
                      match
                        Js.Opt.to_option (dom_sel##.options##item idx)
                      with
                      | Some opt ->
                          let id = Js.to_string opt##.value in
                          let desc =
                            Js.Opt.get opt##.textContent (fun () ->
                                Js.string "" )
                            |> Js.to_string
                          in
                          (* Do something with id and desc *)
                          Helpers.set_local_variable
                            "yoda-state-last-problem-id" id ;
                          Helpers.set_local_variable
                            "yoda-state-last-problem-description" desc ;
                          Js._true
                      | None -> Js._true ) )
               Js._false ) ;
          Lwt.return_unit )
  in
  fetch_and_populate () ; sel
