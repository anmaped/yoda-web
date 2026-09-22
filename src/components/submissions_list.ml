open Js_of_ocaml
open Lwt.Infix
open Js_of_ocaml_tyxml
open Tyxml_js.Html

(* *)

type submission_column =
  | Col_id
  | Col_problem
  | Col_language
  | Col_result
  | Col_time

let sort_column = ref Col_id

let sort_reverse = ref true

let column_title = function
  | Col_id -> I18n.t "submissions_col_id"
  | Col_problem -> I18n.t "submissions_col_problem"
  | Col_language -> I18n.t "submissions_col_language"
  | Col_result -> I18n.t "submissions_col_result"
  | Col_time -> I18n.t "submissions_col_time"

let sort_indicator col =
  if !sort_column <> col then txt ""
  else if !sort_reverse then txt " ▼"
  else txt " ▲"

let compare_submission problems_by_id (a : Api.Openapi.submission)
    (b : Api.Openapi.submission) =
  let result =
    match !sort_column with
    | Col_id -> Int.compare a.id b.id
    | Col_problem ->
        String.compare
          ( Hashtbl.find_opt problems_by_id a.problem_id
          |> Option.map (fun (x : Api.Openapi.problem) -> x.title)
          |> Option.value ~default:"" )
          ( Hashtbl.find_opt problems_by_id b.problem_id
          |> Option.map (fun (x : Api.Openapi.problem) -> x.title)
          |> Option.value ~default:"" )
    | Col_language ->
        String.compare
          (Option.value ~default:"" a.language)
          (Option.value ~default:"" b.language)
    | Col_result -> String.compare a.status b.status
    | Col_time -> Int.compare a.time_ms b.time_ms
  in
  if !sort_reverse then -result else result

(* *)

type submission_status =
  | Accepted
  | WrongAnswer
  | RuntimeError
  | TimeLimitExceeded
  | CompilationError
  | Other of string

let status_of_string = function
  | "accepted" -> Accepted
  | "wrong_answer" -> WrongAnswer
  | "runtime_error" -> RuntimeError
  | "time_limit_exceeded" -> TimeLimitExceeded
  | "compilation_error" -> CompilationError
  | s -> Other s

let status_label = function
  | Accepted -> "Accepted"
  | WrongAnswer -> "Wrong Answer"
  | RuntimeError -> "Runtime Error"
  | TimeLimitExceeded -> "Time Limit Exceeded"
  | CompilationError -> "Compilation Error"
  | Other s -> s

let badge_class = function
  | Accepted -> ["badge"; "text-bg-success"]
  | WrongAnswer -> ["badge"; "text-bg-danger"]
  | _ -> ["badge"; "text-bg-secondary"]

let format_time_ms ms =
  let total = ms / 1000 in
  let h = total / 3600 in
  let m = total mod 3600 / 60 in
  let s = total mod 60 in
  Printf.sprintf "%02d:%02d:%02d" h m s

let submission_row (submission : Api.Openapi.submission) problem lang =
  let id = submission.id in
  let result = status_of_string submission.status in
  let time = format_time_ms submission.time_ms in
  let action_buttons =
    let results_action =
      match Submissions_list_details.action id submission with
      | Some action -> [action]
      | None -> []
    in
    let reeval_action =
      if Helpers.is_judge_or_admin () then
        [ button
            ~a:
              [ a_class ["btn"; "btn-sm"; "btn-outline-warning"]
              ; a_title (I18n.t "submissions_reevaluate")
              ; a_id ("reeval-btn-" ^ string_of_int id)
              ; a_onclick (fun _ ->
                    Lwt.async (fun () ->
                        Api.Helpers.re_evaluate_submission id
                        >>= fun (_, status) ->
                        Console.console##log
                          (Js.string
                             ("Re-eval status: " ^ string_of_int status) ) ;
                        Lwt.return_unit ) ;
                    false ) ]
            [Icons.reeval_icon ()] ]
      else []
    in
    reeval_action @ results_action
  in
  tr
    ( [ td ~a:[a_class ["ps-3"]] [txt (string_of_int id)]
      ; td [txt problem]
      ; td [txt lang]
      ; td
          [span ~a:[a_class (badge_class result)] [txt (status_label result)]]
      ; td [txt time] ]
    @
    if action_buttons = [] then []
    else
      [ td
          ~a:[a_style "text-align:center; vertical-align: middle"]
          [ div
              ~a:[a_class ["d-flex"; "justify-content-center"; "gap-1"]]
              action_buttons ] ] )

let load_submissions table contest_id last =
  Lwt.async (fun () ->
      let url =
        Printf.sprintf "%s/contests/%d/submissions" Api.Helpers.base_url
          contest_id
      in
      Api.Helpers.fetch_json url
      >>= fun (resp, status) ->
      if status <> 200 then (
        Console.console##log
          (Js.string
             (Printf.sprintf "Failed to fetch submissions: %d" status) ) ;
        Lwt.return_unit )
      else
        let submissions : Api.Openapi.submission list =
          Api.Openapi.Submissions.of_yojson resp
        in
        (* Fetch each unique problem once, then reuse the result for every
           submission that references it. *)
        let unique_problem_ids =
          submissions
          |> List.map (fun (sub : Api.Openapi.submission) -> sub.problem_id)
          |> List.sort_uniq Int.compare
        in
        Lwt_list.map_p
          (fun problem_id ->
            let problem_url =
              Printf.sprintf "%s/problems/%d" Api.Helpers.base_url problem_id
            in
            Api.Helpers.fetch_json problem_url
            >>= fun (problem_resp, problem_status) ->
            if problem_status <> 200 then (
              Console.console##log
                (Js.string
                   (Printf.sprintf "Failed to fetch problem: %d"
                      problem_status ) ) ;
              Lwt.return (problem_id, None) )
            else
              let p = Api.Openapi.Problem.of_yojson problem_resp in
              Lwt.return (problem_id, Some p) )
          unique_problem_ids
        >>= fun fetched_problems ->
        let problems_by_id = Hashtbl.create (List.length fetched_problems) in
        List.iter
          (fun (problem_id, problem_opt) ->
            match problem_opt with
            | Some p -> Hashtbl.replace problems_by_id problem_id p
            | None -> () )
          fetched_problems ;
        let submissions =
          submissions |> List.rev
          |> List.sort (compare_submission problems_by_id)
          |> List.filteri (fun i _ -> i < last)
        in
        Lwt_list.map_s
          (fun (sub : Api.Openapi.submission) ->
            match Hashtbl.find_opt problems_by_id sub.problem_id with
            | Some p ->
                let lang = Option.value ~default:"Unknown" sub.language in
                let row = submission_row sub p.code lang in
                Lwt.return_some row
            | None -> Lwt.return_none )
          submissions
        >>= fun rows ->
        (* Insert rows in the same order as submissions *)
        let table_dom = Tyxml_js.To_dom.of_table table in
        (* Remove existing rows *)
        let tbody_dom =
          table_dom##getElementsByTagName (Js.string "tbody")
        in
        ( if tbody_dom##.length > 0 then
            match Js.Opt.to_option (tbody_dom##item 0) with
            | Some node -> Dom.removeChild table_dom node
            | None -> () ) ;
        (* Create new tbody *)
        let new_tbody = Dom_html.createTbody Dom_html.document in
        Dom.appendChild table_dom new_tbody ;
        (* Append rows to tbody *)
        List.iter
          (fun row ->
            match row with
            | Some row ->
                Dom.appendChild new_tbody (Tyxml_js.To_dom.of_tr row)
            | None -> () )
          rows ;
        Lwt.return_unit )

let rec sortable_th ((table, contest_id, last) as x) col =
  th
    ~a:
      [ a_style "cursor:pointer"
      ; a_onclick (fun _ ->
            Console.console##log
              (Js.string
                 (Printf.sprintf "Sorting by column: %s"
                    ( match col with
                    | Col_id -> "ID"
                    | Col_problem -> "Problem"
                    | Col_language -> "Language"
                    | Col_result -> "Result"
                    | Col_time -> "Time" ) ) ) ;
            if !sort_column = col then sort_reverse := not !sort_reverse
            else begin
              sort_column := col ;
              sort_reverse := false
            end ;
            (*Helpers.trigger_render () ;*)
            (* get table *)
            let table_dom = Tyxml_js.To_dom.of_table table in
            (* update table header *)
            let thead_dom =
              table_dom##getElementsByTagName (Js.string "thead")
            in
            ( if thead_dom##.length > 0 then
                match Js.Opt.to_option (thead_dom##item 0) with
                | Some node ->
                    let new_thead = submission_header x () in
                    Dom.replaceChild table_dom
                      (Tyxml_js.To_dom.of_thead new_thead)
                      node
                | None -> () ) ;
            (* reload submissions *)
            load_submissions table contest_id last ;
            false ) ]
    [txt (column_title col); sort_indicator col]

and submission_header x () =
  thead
    ~a:[a_class ["table-light"]]
    [ tr
        ( [ sortable_th x Col_id
          ; sortable_th x Col_problem
          ; sortable_th x Col_language
          ; sortable_th x Col_result
          ; sortable_th x Col_time ]
        @ [ th
              ~a:[a_style "cursor:pointer"]
              [txt (I18n.t "submissions_col_action")] ] ) ]

let content ~contest_id ~last () =
  let table =
    table
      ~a:
        [ a_class
            ["table"; "table-striped"; "table-hover"; "mb-0"; "align-middle"]
        ]
      []
  in
  (* add thead *)
  Dom.appendChild
    (Tyxml_js.To_dom.of_table table)
    (Tyxml_js.To_dom.of_thead
       (submission_header (table, contest_id, last) ()) ) ;
  load_submissions table contest_id last ;
  div ~a:[a_class ["table-responsive"]] [table]
