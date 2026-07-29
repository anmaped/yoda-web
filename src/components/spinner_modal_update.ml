open Js_of_ocaml
open Js_of_ocaml_lwt
open Lwt.Infix

let poll_interval_seconds = 1.0

let terminal_statuses =
  [ "accepted"
  ; "wrong_answer"
  ; "runtime_error"
  ; "time_limit_exceeded"
  ; "memory_limit_exceeded"
  ; "compilation_error"
  ; "compile_error"
  ; "presentation_error"
  ; "internal_error" ]

type submit_context =
  { contest_id: int
  ; problem_code: string
  ; problem_id: int
  ; language: string
  ; source_code: string }

let show_modal () =
  Spinner_modal.remove () ;
  Helpers.add_element_to_app (Spinner_modal.make ())

let is_terminal_status status =
  List.exists (fun s -> s = String.lowercase_ascii status) terminal_statuses

let get_editor_source_code () = Js.to_string Editor.editor##getValue

let parse_problem_id value = try Some (int_of_string value) with _ -> None

let get_submission_context () =
  let contest_id = Helpers.get_current_contest_id () in
  match Helpers.get_local_variable "yoda-state-last-problem-id" with
  | None -> Lwt.return (Error "No selected problem found")
  | Some problem_code_js -> (
      let problem_code = Js.to_string problem_code_js in
      match parse_problem_id problem_code with
      | None ->
          Lwt.return
            (Error
               "Selected problem id is not numeric. Please choose a numeric \
                problem id in the dropdown." )
      | Some problem_id ->
          let language =
            match Helpers.get_local_variable "yoda-state-last-language" with
            | Some value -> Js.to_string value
            | None -> "ocaml"
          in
          let source_code = get_editor_source_code () in
          if String.trim source_code = "" then
            Lwt.return (Error "Editor is empty, nothing to submit")
          else
            Lwt.return
              (Ok
                 {contest_id; problem_code; problem_id; language; source_code}
              ) )

let fetch_submission submission_id =
  let url =
    Printf.sprintf "%s/submissions/%d" Api.Helpers.base_url submission_id
  in
  Api.Helpers.fetch_json url
  >>= fun (resp, status) ->
  if status <> 200 then Lwt.return None
  else
    let submissions = Api.Openapi.Submission.of_yojson resp in
    Lwt.return (Some submissions)

let find_submission_by_id submissions submission_id =
  List.find_opt
    (fun (s : Api.Openapi.submission) -> s.id = submission_id)
    submissions

let submit_solution (ctx : submit_context) =
  let safe_source = Helpers.escape_json_string ctx.source_code in
  let artifact =
    Api.Openapi.SolutionSource_artifacts.create ~filename:"source_code"
      ~content:safe_source ()
  in
  let solution =
    Api.Openapi.Solution.create ~problem_id:ctx.problem_id
      ~language:ctx.language ~source_artifacts:[artifact] ()
  in
  Api.Helpers.submit_solution (Api.Openapi.Solution.to_yojson solution)
  >>= fun (resp, status) ->
  if status <> 200 && status <> 201 && status <> 202 then
    Lwt.return (Error status)
  else
    let submission = Api.Openapi.Submission.of_yojson resp in
    Lwt.return (Ok submission.id)

let rec poll_until_terminal (ctx : submit_context) submission_id =
  fetch_submission submission_id
  >>= function
  | None ->
      Spinner_modal.update_text "Submission queued..." ;
      Lwt_js.sleep poll_interval_seconds
      >>= fun () -> poll_until_terminal ctx submission_id
  | Some submission ->
      let live_status = submission.status in
      Spinner_modal.update_text
        (Printf.sprintf "Status: %s (polling every 1s)" live_status) ;
      if is_terminal_status live_status then (
        (*notify_result ctx live_status ;*)
        Console.console##log
          (Js.string
             (Printf.sprintf "Submission for %s finished with: %s"
                ctx.problem_code live_status ) ) ;
        Lwt_js.sleep 1.0 >>= fun () -> Lwt.return live_status )
      else
        Lwt_js.sleep poll_interval_seconds
        >>= fun () -> poll_until_terminal ctx submission_id

let submit_and_poll () =
  show_modal () ;
  Spinner_modal.update_text "Preparing submission..." ;
  get_submission_context ()
  >>= function
  | Error msg ->
      Spinner_modal.update_text ("Cannot submit: " ^ msg) ;
      Lwt.return_unit
  | Ok ctx -> (
      Spinner_modal.update_text "Sending your solution..." ;
      submit_solution ctx
      >>= function
      | Error code ->
          Spinner_modal.update_text
            (Printf.sprintf "Submission failed with HTTP status %d" code) ;
          Lwt.return_unit
      | Ok submission_id ->
          Spinner_modal.update_text
            (Printf.sprintf "Submission #%d created. Waiting for judge..."
               submission_id ) ;
          poll_until_terminal ctx submission_id
          >>= fun final_status ->
          Spinner_modal.update_text ("Final verdict: " ^ final_status) ;
          Lwt.return_unit )

let start () = Lwt.async submit_and_poll
