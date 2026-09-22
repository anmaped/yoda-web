open Js_of_ocaml
open Js_of_ocaml_tyxml
open Tyxml_js.Html
open Lwt.Infix

let update_language_selection dom_language_select languages =
  let rec clear_options () =
    match Js.Opt.to_option dom_language_select##.firstChild with
    | Some child ->
        Dom.removeChild dom_language_select child ;
        clear_options ()
    | None -> ()
  in
  clear_options () ;
  let add_option value label =
    let opt = Dom_html.createOption Dom_html.document in
    opt##.value := Js.string value ;
    Dom.appendChild opt (Dom_html.document##createTextNode (Js.string label)) ;
    Dom.appendChild dom_language_select opt
  in
  match languages with
  | [] -> add_option "none" "No supported languages"
  | _ -> (
      List.iter (fun language -> add_option language language) languages ;
      let preferred_language =
        match Model.Problem_state.get_selected_problem_language () with
        | Some selected when List.mem selected languages -> Some selected
        | _ -> List.nth_opt languages 0
      in
      match preferred_language with
      | Some language ->
          let options = dom_language_select##.options in
          let rec find_and_select idx =
            if idx >= options##.length then ()
            else
              match Js.Opt.to_option (options##item idx) with
              | Some opt ->
                  if Js.to_string opt##.value = language then (
                    opt##.selected := Js._true ;
                    Model.Problem_state.set_current_problem_language language
                    )
                  else find_and_select (idx + 1)
              | None -> find_and_select (idx + 1)
          in
          find_and_select 0
      | None -> () )

let update_current_problem dom_problem_selection dom_language_select =
  let selected_problem () =
    let idx = dom_problem_selection##.selectedIndex in
    if idx <= 0 then None
    else
      match Js.Opt.to_option (dom_problem_selection##.options##item idx) with
      | None -> None
      | Some opt ->
          let id = Js.to_string opt##.value |> int_of_string in
          let desc =
            Js.Opt.get opt##.textContent (fun () -> Js.string "")
            |> Js.to_string
          in
          Some (id, desc)
  in
  match selected_problem () with
  | None -> Lwt.return_unit
  | Some (id, desc) ->
      Model.Problem_state.set_current_problem_id id ;
      Model.Problem_state.set_current_problem_description desc ;
      (* Update the tabbar with the selected problem asynchronously *)
      Tabbar.update id ()
      >>= fun () ->
      (* wait for the update to complete *)
      let languages = Tabbar.get_current_languages () in
      update_language_selection dom_language_select languages ;
      Lwt.return_unit

let content () =
  let language_select =
    select
      ~a:
        [ a_id "problem-language-select"
        ; a_class ["form-select"; "w-auto"; "ms-2"] ]
      []
  in
  (* Update when language selection changes *)
  let dom_language_select = Tyxml_js.To_dom.of_select language_select in
  ignore
    (Dom_html.addEventListener dom_language_select Dom_html.Event.change
       (Dom_html.handler (fun _ ->
            match
              Js.Opt.to_option
                (dom_language_select##.options##item
                   dom_language_select##.selectedIndex )
            with
            | Some opt ->
                let value = Js.to_string opt##.value in
                if value <> "" && value <> "none" then (
                  Model.Problem_state.set_current_problem_language value ;
                  Tabbar.update_tab_div_dom () ) ;
                Js._false
            | None -> Js._false ) )
       Js._false ) ;
  let problem_select =
    select
      ~a:[a_id "problem-select"; a_class ["form-select"; "w-auto"]]
      [option ~a:[a_value ""] (txt (I18n.t "dropdown_select_problem"))]
  in
  let dom_problem_selection = Tyxml_js.To_dom.of_select problem_select in
  (* Update when problem selection changes *)
  ignore
    (Dom_html.addEventListener dom_problem_selection Dom_html.Event.change
       (Dom_html.handler (fun _ ->
            Lwt.async (fun () ->
                update_current_problem dom_problem_selection
                  dom_language_select ) ;
            Js._false ) )
       Js._false ) ;
  let wrapper =
    div
      ~a:[a_class ["d-flex"; "align-items-center"; "gap-2"]]
      [problem_select; language_select]
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
          (* Clear existing options *)
          (* Remove all options *)
          while dom_problem_selection##.length > 0 do
            dom_problem_selection##remove 0
          done ;
          (* Add option *)
          let add_option value label =
            let opt = Dom_html.createOption Dom_html.document in
            opt##.value := Js.string value ;
            Dom.appendChild opt
              (Dom_html.document##createTextNode (Js.string label)) ;
            Dom.appendChild dom_problem_selection opt
          in
          (* Add default option *)
          add_option "" (I18n.t "dropdown_select_problem") ;
          (* Build option elements *)
          (* Add problem options *)
          List.iter
            (fun (p : Api.Openapi.problem) ->
              add_option
                (string_of_int (Option.value ~default:(-1) p.id))
                (p.code ^ ": " ^ p.title) )
            problems ;
          (* Set last problem as selected if none is selected or invalid *)
          let select_problem code =
            let options = dom_problem_selection##.options in
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
          let () =
            match Model.Problem_state.get_selected_problem_id () with
            | Some code -> select_problem (string_of_int code)
            | None -> (
              match List.rev problems with
              | last_problem :: _ ->
                  Model.Problem_state.set_current_problem_id
                    (Option.value ~default:(-1) last_problem.id) ;
                  Model.Problem_state.set_current_problem_description
                    (last_problem.code ^ ": " ^ last_problem.title) ;
                  select_problem last_problem.code
              | [] -> () )
          in
          (* Update tabbar with current pid *)
          update_current_problem dom_problem_selection dom_language_select )
  in
  fetch_and_populate () ; wrapper
