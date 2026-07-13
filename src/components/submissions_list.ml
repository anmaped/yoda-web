open Js_of_ocaml
open Js_of_ocaml_lwt
open Lwt.Infix
open Js_of_ocaml_tyxml
open Tyxml_js.Html

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

let submission_row id problem lang result time =
  tr
    [ td ~a:[a_class ["ps-3"]] [txt (string_of_int id)]
    ; td [txt problem]
    ; td [txt lang]
    ; td [span ~a:[a_class (badge_class result)] [txt (status_label result)]]
    ; td [txt time] ]

let content ~contest_id () =
  let table =
    table
      ~a:
        [ a_class
            ["table"; "table-striped"; "table-hover"; "mb-0"; "align-middle"]
        ]
      ~thead:
        (thead
           ~a:[a_class ["table-light"]]
           [ tr
               [ th [txt "#"]
               ; th [txt "Problem"]
               ; th [txt "Language"]
               ; th [txt "Result"]
               ; th [txt "Time"] ] ] )
      []
  in
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
      else (* code 200 *)
        let resp_json_string = Js.to_string (Json.output resp) in
        let submissions : Api.Openapi.submission list =
          Api.Openapi.ContestsContestidSubmissionsGetResponse2.of_json
            resp_json_string
        in
        List.iter
          (fun (sub : Api.Openapi.submission) ->
            let id = sub.id in
            let status = status_of_string sub.status in
            let time_str = format_time_ms sub.time_ms in
            (* fetch problem title for the submission *)
            Lwt.async (fun () ->
                Api.Helpers.fetch_json
                  (Printf.sprintf "%s/problems/%d" Api.Helpers.base_url
                     sub.problem_id )
                >>= fun (problem_resp, problem_status) ->
                if problem_status <> 200 then (
                  Console.console##log
                    (Js.string
                       (Printf.sprintf "Failed to fetch problem: %d"
                          problem_status ) ) ;
                  Lwt.return_unit )
                else
                  let p =
                    Api.Openapi.Problem.of_json
                      (Js.to_string (Json.output problem_resp))
                  in
                  (* let lang = match Js.Opt.get sub.language (fun () ->
                     Js.string "Unknown") with | s -> Js.to_string s in*)
                  let lang = "Unknown" in
                  let row = submission_row id p.code lang status time_str in
                  Dom.appendChild
                    (Tyxml_js.To_dom.of_table table)
                    (Tyxml_js.To_dom.of_tr row) ;
                  Lwt.return_unit ) )
          submissions ;
        Lwt.return_unit ) ;
  div ~a:[a_class ["table-responsive"]] [table]
