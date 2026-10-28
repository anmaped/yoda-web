open Js_of_ocaml
open Js_of_ocaml_lwt
open Js_of_ocaml_tyxml
open Tyxml_js.Html
open Lwt.Infix

type config =
  {endpoint: string; model: string; api_key: string; prompt: string}

type input =
  { contest_id: int
  ; submission_id: int
  ; filename: string
  ; problem_code: string
  ; attempts: int
  ; verdict: string
  ; source: string }

let job_key input =
  Printf.sprintf "llm:%s:%d:%d:%s" (Helpers.get_username ()) input.contest_id
    input.submission_id input.filename

let subscribe on_change =
  Model.Job_queue.subscribe (fun key _ ->
      if Astring.String.is_prefix ~affix:"llm:" key then on_change () )

let markdown_response response =
  let content =
    div ~a:[a_class ["markdown-content"; "judge-llm-response"]] [txt response]
  in
  if Js.Optdef.test (Js.Unsafe.get Js.Unsafe.global "markdownit") then
    (Tyxml_js.To_dom.of_div content)##.innerHTML
    := Js.string
         (View_problem_markdown.render_markdown ~allow_html:false response) ;
  content

let result_cell ~input ~result =
  let status = Model.Job_queue.status (job_key input) in
  td
    ( match result with
    | None ->
        [ txt
            ( match status with
            | Some Model.Job_queue.Queued -> "Queued"
            | Some Model.Job_queue.Running -> "Evaluating..."
            | _ -> "Not evaluated" ) ]
    | Some (response, true) ->
        [span ~a:[a_class ["text-danger"]] [txt response]]
    | Some (response, false) -> [markdown_response response] )

let enqueue ~input ~config ~on_result =
  let username = Helpers.get_username () in
  ignore
    (Model.Job_queue.enqueue ~key:(job_key input)
       ~run:(fun () ->
         if
           Helpers.get_username () <> username
           || not (Helpers.is_judge_or_admin ())
         then failwith "Evaluation canceled after sign-out." ;
         let body =
           `Assoc
             [ ("model", `String config.model)
             ; ( "messages"
               , `List
                   [ `Assoc
                       [ ("role", `String "system")
                       ; ("content", `String config.prompt) ]
                   ; `Assoc
                       [ ("role", `String "user")
                       ; ( "content"
                         , `String
                             (Printf.sprintf
                                "Problem %s, submission %d, file %s, \
                                 attempts so far %d, judge verdict %s. \
                                 Source:\n\
                                 %s"
                                input.problem_code input.submission_id
                                input.filename input.attempts input.verdict
                                input.source ) ) ] ] ) ]
           |> Yojson.Safe.to_string
         in
         XmlHttpRequest.perform_raw_url ~override_method:`POST
           ~headers:
             [ ("Content-Type", "application/json")
             ; ("Authorization", "Bearer " ^ config.api_key) ]
           ~contents:(`String body) config.endpoint
         >>= fun response ->
         if response.code < 200 || response.code >= 300 then
           failwith
             (Printf.sprintf "Provider returned HTTP %d." response.code) ;
         let content =
           try
             let json = Yojson.Safe.from_string response.content in
             Yojson.Safe.Util.(json |> member "choices" |> to_list)
             |> List.hd
             |> Yojson.Safe.Util.member "message"
             |> Yojson.Safe.Util.member "content"
             |> Yojson.Safe.Util.to_string
           with _ ->
             failwith "Provider response did not include message content."
         in
         Lwt.return content )
       ~on_result:(fun outcome ->
         if Helpers.get_username () = username then
           match outcome with
           | Ok content -> on_result content false
           | Error (Failure message) -> on_result message true
           | Error _ ->
               on_result
                 "Request failed. Check endpoint, proxy, CORS policy, and \
                  network access."
                 true ) )

let action_button ~input ~config ~on_result =
  let status = Model.Job_queue.status (job_key input) in
  button
    ~a:
      ( [ a_class ["btn"; "btn-sm"; "btn-outline-primary"]
        ; a_title "Evaluate with LLM"
        ; a_aria "label" ["Evaluate with LLM"]
        ; a_onclick (fun _ ->
              Option.iter
                (fun config -> enqueue ~input ~config ~on_result)
                config ;
              false ) ]
      @
      if
        config = None
        || status = Some Model.Job_queue.Queued
        || status = Some Model.Job_queue.Running
      then [a_disabled ()]
      else [] )
    [Icons.robot_icon ()]
