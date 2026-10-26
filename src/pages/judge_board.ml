open Js_of_ocaml
open Js_of_ocaml_lwt
open Js_of_ocaml_tyxml
open Tyxml_js.Html
open Lwt.Infix

type file_entry =
  { submission: Api.Openapi.submission
  ; filename: string
  ; content: string
  ; distance: int option
  ; relative_distance: float option }

type evaluation = {entry: file_entry; response: string; error: bool}

let contest = ref (-1)

let contest_details : Api.Openapi.contest option ref = ref None

let submissions : Api.Openapi.submission list ref = ref []

let selected_user : int option ref = ref None

let usernames : (int, string) Hashtbl.t = Hashtbl.create 32

let problem_codes : (int, string) Hashtbl.t = Hashtbl.create 32

let problem_code id =
  Option.value
    ~default:("Problem #" ^ string_of_int id)
    (Hashtbl.find_opt problem_codes id)

let files : file_entry list ref = ref []

let evaluations : evaluation list ref = ref []

let loading = ref false

let analyzing = ref false

let evaluating : (int * string) option ref = ref None

let reevaluating : int option ref = ref None

let reevaluation_notice = ref ""

let generation = ref 0

let message = ref ""

type metric =
  { key: string
  ; label: string
  ; unit_name: string
  ; relative_basis: string
  ; calculate: string -> string -> (int * float) option }

module IntSet = Set.Make (Int)
module StringSet = Set.Make (String)

let hamming a b =
  let count = ref (abs (String.length a - String.length b)) in
  for i = 0 to min (String.length a) (String.length b) - 1 do
    if a.[i] <> b.[i] then incr count
  done ;
  !count

let relative distance size =
  if size = 0 then 0. else 100. *. float distance /. float size

let levenshtein a b =
  let longer, shorter =
    if String.length a >= String.length b then (a, b) else (b, a)
  in
  let n = String.length longer and m = String.length shorter in
  if m = 0 then Some n
  else if n > 2_000_000 / m then None
  else
    let previous = ref (Array.init (m + 1) Fun.id) in
    let current = ref (Array.make (m + 1) 0) in
    for i = 1 to n do
      let prev = !previous and curr = !current in
      curr.(0) <- i ;
      for j = 1 to m do
        let cost = if longer.[i - 1] = shorter.[j - 1] then 0 else 1 in
        curr.(j) <-
          min (prev.(j) + 1) (min (curr.(j - 1) + 1) (prev.(j - 1) + cost))
      done ;
      previous := curr ;
      current := prev
    done ;
    Some !previous.(m)

let tokens source =
  let result = ref StringSet.empty in
  let word = Buffer.create 32 in
  let flush () =
    if Buffer.length word > 0 then (
      result := StringSet.add (Buffer.contents word) !result ;
      Buffer.clear word )
  in
  String.iter
    (fun c ->
      match c with
      | 'a' .. 'z' | 'A' .. 'Z' | '0' .. '9' | '_' -> Buffer.add_char word c
      | ' ' | '\n' | '\r' | '\t' -> flush ()
      | _ ->
          flush () ;
          result := StringSet.add (String.make 1 c) !result )
    source ;
  flush () ;
  !result

let metrics =
  [ { key= "hamming"
    ; label= "Hamming (position-by-position)"
    ; unit_name= "bytes"
    ; relative_basis= "the longer file length"
    ; calculate=
        (fun a b ->
          let distance = hamming a b in
          Some
            ( distance
            , relative distance (max (String.length a) (String.length b)) ) )
    }
  ; { key= "levenshtein"
    ; label= "Levenshtein (insertions, deletions, substitutions)"
    ; unit_name= "edits"
    ; relative_basis= "the longer file length"
    ; calculate=
        (fun a b ->
          Option.map
            (fun distance ->
              ( distance
              , relative distance (max (String.length a) (String.length b))
              ) )
            (levenshtein a b) ) }
  ; { key= "tokens"
    ; label= "Token Jaccard (whitespace ignored)"
    ; unit_name= "unique tokens"
    ; relative_basis= "the unique-token union size"
    ; calculate=
        (fun a b ->
          let left = tokens a and right = tokens b in
          let union = StringSet.union left right in
          let distance =
            StringSet.cardinal union
            - StringSet.cardinal (StringSet.inter left right)
          in
          Some (distance, relative distance (StringSet.cardinal union)) ) }
  ]

let selected_metric = ref (List.hd metrics)

let rerender () =
  if Js.to_string Dom_html.window##.location##.hash = "#judge-board" then
    Helpers.trigger_render ()

let load_contest_details contest_id =
  Lwt.async (fun () ->
      Lwt.catch
        (fun () ->
          Api.Helpers.get_contest contest_id
          >>= fun (json, status) ->
          if status = 200 && !contest = contest_id then (
            contest_details := Some (Api.Openapi.Contest.of_yojson json) ;
            rerender () ) ;
          Lwt.return_unit )
        (fun _ -> Lwt.return_unit) )

let visible_submissions () =
  match !selected_user with
  | None -> !submissions
  | Some user_id ->
      List.filter
        (fun (sub : Api.Openapi.submission) -> sub.owner_id = Some user_id)
        !submissions

let select_user user_id =
  incr generation ;
  selected_user := user_id ;
  files := [] ;
  evaluations := [] ;
  analyzing := false ;
  evaluating := None ;
  reevaluating := None ;
  reevaluation_notice := "" ;
  message := ""

let user_selector ~on_select () =
  let ids =
    List.filter_map
      (fun (sub : Api.Openapi.submission) -> sub.owner_id)
      !submissions
    |> List.sort_uniq Int.compare
    |> List.filter (Hashtbl.mem usernames)
  in
  label
    ~a:[a_class ["d-block"; "mb-3"]]
    [ span
        ~a:[a_class ["d-block"; "fw-semibold"; "mb-1"]]
        [txt "View submissions for"]
    ; select
        ~a:
          [ a_class ["form-select"]
          ; a_style "max-width:24rem"
          ; a_onchange (fun event ->
                let target =
                  Js.Opt.get event##.target (fun () -> assert false)
                in
                let field =
                  Js.Opt.get (Dom_html.CoerceTo.select target) (fun () ->
                      assert false )
                in
                let value = Js.to_string field##.value in
                select_user
                  (if value = "" then None else Some (int_of_string value)) ;
                on_select () ;
                false ) ]
        ( option
            ~a:
              ( [a_value ""]
              @ if !selected_user = None then [a_selected ()] else [] )
            (txt "All users (contest overview)")
        :: List.map
             (fun id ->
               option
                 ~a:
                   ( [a_value (string_of_int id)]
                   @ if !selected_user = Some id then [a_selected ()] else []
                   )
                 (txt (Hashtbl.find usernames id)) )
             ids ) ]

let load ~on_loaded contest_id =
  incr generation ;
  let request_generation = !generation in
  loading := true ;
  submissions := [] ;
  files := [] ;
  evaluations := [] ;
  evaluating := None ;
  reevaluating := None ;
  reevaluation_notice := "" ;
  let url =
    Printf.sprintf "%s/contests/%d/submissions" Api.Helpers.base_url
      contest_id
  in
  Lwt.async (fun () ->
      Lwt.catch
        (fun () ->
          Api.Helpers.fetch_json url
          >>= fun (json, code) ->
          ( if code <> 200 then Lwt.return ([], [])
            else
              Lwt.both
                (Lwt.catch
                   (fun () ->
                     Api.Helpers.get_admin_users ()
                     >|= fun (users_json, users_code) ->
                     if users_code = 200 then
                       Api.Openapi.AdminUsersGetResponse2.of_yojson
                         users_json
                     else [] )
                   (fun _ -> Lwt.return []) )
                (Lwt.catch
                   (fun () ->
                     Api.Helpers.get_problems contest_id
                     >|= fun (problems_json, problems_code) ->
                     if problems_code = 200 then
                       Api.Openapi.ContestsContestsidProblemsGetResponse2
                       .of_yojson problems_json
                     else [] )
                   (fun _ -> Lwt.return []) ) )
          >>= fun (users, problems) ->
          if !contest = contest_id && !generation = request_generation then (
            if code = 200 then (
              submissions := Api.Openapi.Submissions.of_yojson json ;
              Hashtbl.clear usernames ;
              List.iter
                (fun (user : Api.Openapi.user) ->
                  Hashtbl.replace usernames user.id user.username )
                users ;
              Hashtbl.clear problem_codes ;
              List.iter
                (fun (problem : Api.Openapi.problem) ->
                  Option.iter
                    (fun id -> Hashtbl.replace problem_codes id problem.code)
                    problem.id )
                problems ;
              ( match !selected_user with
              | Some id
                when (not
                        (List.exists
                           (fun (sub : Api.Openapi.submission) ->
                             sub.owner_id = Some id )
                           !submissions ) )
                     || not (Hashtbl.mem usernames id) ->
                  selected_user := None
              | _ -> () ) ;
              message := "" )
            else (
              selected_user := None ;
              message :=
                Printf.sprintf "Submissions request failed (%d)." code ) ;
            loading := false ;
            if code = 200 then on_loaded () ;
            rerender () ) ;
          Lwt.return_unit )
        (fun _ ->
          if !contest = contest_id && !generation = request_generation then (
            loading := false ;
            selected_user := None ;
            message := "Could not load submissions." ;
            rerender () ) ;
          Lwt.return_unit ) )

let analyze contest_id =
  if not !analyzing then (
    let request_generation = !generation in
    let metric = !selected_metric in
    analyzing := true ;
    message :=
      "Loading source files for the current view's latest 50 submissions..." ;
    rerender () ;
    let recent =
      List.sort
        (fun (a : Api.Openapi.submission) b -> Int.compare b.id a.id)
        (visible_submissions ())
      |> List.filteri (fun i _ -> i < 50)
    in
    let pool = Lwt_pool.create 5 (fun () -> Lwt.return_unit) in
    Lwt.async (fun () ->
        Lwt_list.map_p
          (fun (sub : Api.Openapi.submission) ->
            Lwt_pool.use pool (fun () ->
                Lwt.catch
                  (fun () ->
                    Api.Helpers.fetch_json
                      (Printf.sprintf "%s/submissions/%d/details"
                         Api.Helpers.base_url sub.id )
                    >|= fun (json, code) ->
                    if code <> 200 then []
                    else
                      let details =
                        Api.Openapi.SubmissionFullDetails.of_yojson json
                      in
                      List.map
                        (fun (source : Api.Openapi.sourceArtifact) ->
                          { submission= sub
                          ; filename= source.filename
                          ; content= source.content
                          ; distance= None
                          ; relative_distance= None } )
                        details.source_artifacts )
                  (fun _ -> Lwt.return []) ) )
          recent
        >>= fun fetched ->
        if !contest = contest_id && !generation = request_generation then (
          let previous = Hashtbl.create 32 in
          let skipped = ref 0 in
          files :=
            List.concat fetched
            |> List.sort (fun a b ->
                Int.compare a.submission.id b.submission.id )
            |> List.map (fun entry ->
                let key =
                  ( entry.submission.owner_id
                  , entry.submission.problem_id
                  , entry.filename )
                in
                let distance, relative_distance =
                  match
                    (entry.submission.owner_id, Hashtbl.find_opt previous key)
                  with
                  | Some _, Some content -> (
                    match metric.calculate content entry.content with
                    | Some (distance, relative) ->
                        (Some distance, Some relative)
                    | None -> incr skipped ; (None, None) )
                  | _ -> (None, None)
                in
                if entry.submission.owner_id <> None then
                  Hashtbl.replace previous key entry.content ;
                {entry with distance; relative_distance} ) ;
          let unavailable =
            List.length recent
            - List.length (List.filter (fun xs -> xs <> []) fetched)
          in
          message :=
            ( if unavailable = 0 then ""
              else
                Printf.sprintf
                  "%d submission(s) have no accessible source files. "
                  unavailable )
            ^
            if !skipped = 0 then ""
            else
              Printf.sprintf
                "%d file pair(s) exceeded the 2-million-cell edit-distance \
                 limit."
                !skipped ;
          analyzing := false ;
          rerender () ) ;
        Lwt.return_unit ) )

let attempts entry =
  List.fold_left
    (fun count (sub : Api.Openapi.submission) ->
      if
        entry.submission.owner_id <> None
        && sub.owner_id = entry.submission.owner_id
        && sub.problem_id = entry.submission.problem_id
        && sub.id <= entry.submission.id
      then count + 1
      else count )
    0 (visible_submissions ())

let evaluate entry =
  match Settings_llm.configuration () with
  | None -> ()
  | Some config when !evaluating = None ->
      let key = (entry.submission.id, entry.filename) in
      let request_generation = !generation in
      evaluating := Some key ;
      rerender () ;
      Lwt.async (fun () ->
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
                                 (problem_code entry.submission.problem_id)
                                 entry.submission.id entry.filename
                                 (attempts entry) entry.submission.status
                                 entry.content ) ) ] ] ) ]
            |> Yojson.Safe.to_string
          in
          Lwt.catch
            (fun () ->
              XmlHttpRequest.perform_raw_url ~override_method:`POST
                ~headers:
                  [ ("Content-Type", "application/json")
                  ; ("Authorization", "Bearer " ^ config.api_key) ]
                ~contents:(`String body) config.endpoint
              >>= fun response ->
              let text, error =
                if response.code < 200 || response.code >= 300 then
                  ( Printf.sprintf "Provider returned HTTP %d." response.code
                  , true )
                else
                  try
                    let json = Yojson.Safe.from_string response.content in
                    Yojson.Safe.Util.(json |> member "choices" |> to_list)
                    |> List.hd
                    |> Yojson.Safe.Util.member "message"
                    |> Yojson.Safe.Util.member "content"
                    |> Yojson.Safe.Util.to_string
                    |> fun content -> (content, false)
                  with _ ->
                    ( "Provider response did not include message content."
                    , true )
              in
              if !evaluating = Some key && !generation = request_generation
              then (
                evaluations :=
                  {entry; response= text; error}
                  :: List.filter
                       (fun result ->
                         (result.entry.submission.id, result.entry.filename)
                         <> key )
                       !evaluations ;
                evaluating := None ;
                rerender () ) ;
              Lwt.return_unit )
            (fun _ ->
              if !evaluating = Some key && !generation = request_generation
              then (
                evaluations :=
                  { entry
                  ; response=
                      "Request failed. Check endpoint, CORS policy, and \
                       network access."
                  ; error= true }
                  :: !evaluations ;
                evaluating := None ;
                rerender () ) ;
              Lwt.return_unit ) )
  | Some _ -> ()

let request_reevaluation submission_id =
  if Helpers.is_judge_or_admin () && !reevaluating = None then (
    reevaluating := Some submission_id ;
    reevaluation_notice := "" ;
    rerender () ;
    Lwt.async (fun () ->
        Lwt.catch
          (fun () ->
            Api.Helpers.re_evaluate_submission submission_id
            >>= fun (_, status) ->
            if !reevaluating = Some submission_id then (
              reevaluation_notice :=
                if status >= 200 && status < 300 then
                  Printf.sprintf
                    "Re-evaluation requested for submission #%d. Refresh to \
                     see the updated verdict."
                    submission_id
                else
                  Printf.sprintf
                    "Re-evaluation of submission #%d failed (HTTP %d)."
                    submission_id status ;
              reevaluating := None ;
              rerender () ) ;
            Lwt.return_unit )
          (fun _ ->
            if !reevaluating = Some submission_id then (
              reevaluation_notice :=
                Printf.sprintf
                  "Could not request re-evaluation of submission #%d."
                  submission_id ;
              reevaluating := None ;
              rerender () ) ;
            Lwt.return_unit ) ) )

let status_rank = function
  | "accepted" -> 0
  | "wrong_answer" -> 1
  | "time_limit_exceeded" -> 2
  | "memory_limit_exceeded" -> 3
  | "runtime_error" -> 4
  | "compilation_error" | "compile_error" -> 5
  | "presentation_error" -> 6
  | "internal_error" -> 7
  | "running" -> 8
  | "queued" -> 9
  | "pending" -> 10
  | _ -> 11

let status_color = function
  | "accepted" -> "accepted"
  | "wrong_answer" -> "wrong-answer"
  | "time_limit_exceeded" -> "time-limit"
  | "memory_limit_exceeded" -> "memory-limit"
  | "runtime_error" -> "runtime-error"
  | "compilation_error" | "compile_error" -> "compilation-error"
  | "presentation_error" -> "presentation-error"
  | "internal_error" -> "internal-error"
  | "running" -> "running"
  | "queued" -> "queued"
  | "pending" -> "pending"
  | _ -> "other"

let histogram ?(show_users = false) ~title submissions =
  let counts = Hashtbl.create 16 in
  let users_by_problem = Hashtbl.create 16 in
  List.iter
    (fun (sub : Api.Openapi.submission) ->
      let statuses =
        match Hashtbl.find_opt counts sub.problem_id with
        | Some statuses -> statuses
        | None ->
            let statuses = Hashtbl.create 8 in
            Hashtbl.add counts sub.problem_id statuses ;
            statuses
      in
      let status = sub.status in
      Hashtbl.replace statuses status
        (1 + Option.value ~default:0 (Hashtbl.find_opt statuses status)) ;
      match sub.owner_id with
      | None -> ()
      | Some user_id ->
          let users =
            Option.value ~default:IntSet.empty
              (Hashtbl.find_opt users_by_problem sub.problem_id)
          in
          Hashtbl.replace users_by_problem sub.problem_id
            (IntSet.add user_id users) )
    submissions ;
  let rows =
    Hashtbl.fold
      (fun id statuses acc ->
        let breakdown =
          Hashtbl.fold
            (fun status count xs -> (status, count) :: xs)
            statuses []
          |> List.sort (fun (a, _) (b, _) ->
              let order = Int.compare (status_rank a) (status_rank b) in
              if order = 0 then String.compare a b else order )
        in
        let total =
          List.fold_left (fun n (_, count) -> n + count) 0 breakdown
        in
        (id, total, breakdown) :: acc )
      counts []
    |> List.sort (fun (a, _, _) (b, _, _) -> Int.compare a b)
  in
  let peak = List.fold_left (fun n (_, count, _) -> max n count) 1 rows in
  let unique_users =
    submissions
    |> List.filter_map (fun (sub : Api.Openapi.submission) -> sub.owner_id)
    |> List.sort_uniq Int.compare
    |> List.length
  in
  div
    ~a:[a_class ["card"; "p-3"; "mb-3"]]
    ( [ h2 ~a:[a_class ["h5"]] [txt title]
      ; p
          ~a:[a_class ["text-muted"; "small"]]
          [ txt
              "Bar length compares submission totals across problems; \
               colors show judge verdicts. Counts include every submission, \
               not just each user's latest verdict." ] ]
    @ ( if show_users then
          [ p
              ~a:[a_class ["text-muted"]]
              [ txt
                  (Printf.sprintf "%d submissions from %d users"
                     (List.length submissions) unique_users ) ] ]
        else
          [ p
              ~a:[a_class ["text-muted"]]
              [ txt
                  (Printf.sprintf "%d submissions in current view"
                     (List.length submissions) ) ] ] )
    @
    if rows = [] then [p [txt "No submissions available."]]
    else
      List.map
        (fun (id, count, breakdown) ->
          div
            ~a:[a_class ["judge-status-row"]]
            [ div
                ~a:
                  [ a_class
                      [ "d-flex"
                      ; "flex-wrap"
                      ; "justify-content-between"
                      ; "gap-2" ] ]
                [ strong [txt (problem_code id)]
                ; span
                    ~a:[a_class ["text-muted"; "small"]]
                    [ txt
                        ( if show_users then
                            Printf.sprintf "%d submissions from %d users"
                              count
                              ( Hashtbl.find_opt users_by_problem id
                              |> Option.value ~default:IntSet.empty
                              |> IntSet.cardinal )
                          else Printf.sprintf "%d submissions" count ) ] ]
            ; div
                ~a:
                  [ a_class ["judge-status-bar"]
                  ; a_aria "label"
                      [ Printf.sprintf "%s: %d submissions" (problem_code id)
                          count ] ]
                (List.map
                   (fun (status, amount) ->
                     div
                       ~a:
                         [ a_class
                             [ "judge-status-segment"
                             ; "judge-status-" ^ status_color status ]
                         ; a_style
                             (Printf.sprintf "width:%.4f%%"
                                (100. *. float amount /. float peak) )
                         ; a_title
                             (Printf.sprintf "%s: %d"
                                (I18n.submission_status status)
                                amount ) ]
                       [] )
                   breakdown )
            ; div
                ~a:[a_class ["judge-status-breakdown"]]
                (List.map
                   (fun (status, amount) ->
                     span
                       ~a:[a_class ["judge-status-item"]]
                       [ span
                           ~a:
                             [ a_class
                                 [ "judge-status-swatch"
                                 ; "judge-status-" ^ status_color status ] ]
                           []
                       ; txt
                           (Printf.sprintf "%s %d"
                              (I18n.submission_status status)
                              amount ) ] )
                   breakdown ) ] )
        rows )

let distance_plot () =
  let problem_ids =
    visible_submissions ()
    |> List.map (fun (sub : Api.Openapi.submission) -> sub.problem_id)
    |> List.sort_uniq Int.compare
  in
  let plot_problem problem_id =
    let measured =
      List.filter_map
        (fun file ->
          if file.submission.problem_id = problem_id then
            Option.map (fun d -> (file, d)) file.distance
          else None )
        !files
    in
    let n = List.length measured in
    let peak = List.fold_left (fun p (_, d) -> max p d) 1 measured in
    let points =
      List.mapi
        (fun i (_, d) ->
          ( 10. +. (980. *. float i /. float (max 1 (n - 1)))
          , 175. -. (155. *. float d /. float peak) ) )
        measured
    in
    let path =
      points
      |> List.mapi (fun i (x, y) ->
          Printf.sprintf "%s %.2f %.2f" (if i = 0 then "M" else "L") x y )
      |> String.concat " "
    in
    div
      ~a:[a_class ["mb-4"]]
      [ h3 ~a:[a_class ["h6"]] [txt (problem_code problem_id)]
      ; ( if n = 0 then
            p
              ~a:[a_class ["text-muted"]]
              [txt "No comparable file pairs in the analyzed submissions."]
          else
            div
              [ Tyxml_js.Html.svg
                  ~a:
                    [ Tyxml_js.Svg.a_class ["judge-distance-chart"]
                    ; Tyxml_js.Svg.a_viewBox (0., 0., 1000., 190.) ]
                  ( Tyxml_js.Svg.path
                      ~a:
                        [ Tyxml_js.Svg.a_d path
                        ; Tyxml_js.Svg.a_class ["judge-distance-line"] ]
                      []
                  :: List.map2
                       (fun (file, distance) (x, y) ->
                         Tyxml_js.Svg.circle
                           ~a:
                             [ Tyxml_js.Svg.a_cx (x, None)
                             ; Tyxml_js.Svg.a_cy (y, None)
                             ; Tyxml_js.Svg.a_r (6., None)
                             ; Tyxml_js.Svg.a_class ["judge-distance-dot"] ]
                           [ Tyxml_js.Svg.title
                               (Tyxml_js.Svg.txt
                                  (Printf.sprintf
                                     "Submission #%d, %s: %d %s (%.2f%% \
                                      relative)"
                                     file.submission.id file.filename
                                     distance !selected_metric.unit_name
                                     (Option.value ~default:0.
                                        file.relative_distance ) ) ) ] )
                       measured points )
              ; small
                  ~a:[a_class ["text-muted"]]
                  [ txt
                      (Printf.sprintf
                         "%d comparable files; maximum distance %d %s. \
                          Points follow submission order."
                         n peak !selected_metric.unit_name ) ] ] ) ]
  in
  div
    ~a:[a_class ["card"; "p-3"; "mb-3"; "w-100"]]
    ( [ h2 ~a:[a_class ["h5"]] [txt "Submission file distance by problem"]
      ; p
          ~a:[a_class ["text-muted"]]
          [ txt
              ( !selected_metric.label
              ^ " compares each file only with an earlier file from the \
                 same owner, problem and filename. First files have no \
                 predecessor. Only accessible sources from the current \
                 view's latest 50 submissions are analyzed. Relative \
                 distance is the raw distance divided by "
              ^ !selected_metric.relative_basis ^ "." ) ] ]
    @ ( match !selected_metric.key with
      | "tokens" ->
          [ p
              ~a:[a_class ["text-muted"]]
              [ txt
                  "Token Jaccard ignores whitespace, token order and \
                   repeated tokens; comments still count." ] ]
      | "levenshtein" ->
          [ p
              ~a:[a_class ["text-muted"]]
              [ txt
                  "Edit distance is limited to 2 million comparison cells \
                   per file pair; larger pairs are omitted." ] ]
      | _ -> [] )
    @
    if problem_ids = [] then [p [txt "No submissions in this view."]]
    else List.map plot_problem problem_ids )

let metric_selector ~on_select () =
  label
    ~a:[a_class ["d-block"; "mb-3"]]
    [ span
        ~a:[a_class ["d-block"; "fw-semibold"; "mb-1"]]
        [txt "File distance metric"]
    ; select
        ~a:
          [ a_class ["form-select"]
          ; a_style "max-width:30rem"
          ; a_onchange (fun event ->
                let target =
                  Js.Opt.get event##.target (fun () -> assert false)
                in
                let field =
                  Js.Opt.get (Dom_html.CoerceTo.select target) (fun () ->
                      assert false )
                in
                let key = Js.to_string field##.value in
                ( match
                    List.find_opt (fun metric -> metric.key = key) metrics
                  with
                | Some metric when metric.key <> !selected_metric.key ->
                    incr generation ;
                    selected_metric := metric ;
                    analyzing := false ;
                    evaluating := None ;
                    files := [] ;
                    message := "" ;
                    on_select ()
                | _ -> () ) ;
                false ) ]
        (List.map
           (fun metric ->
             option
               ~a:
                 ( [a_value metric.key]
                 @
                 if metric.key = !selected_metric.key then [a_selected ()]
                 else [] )
               (txt metric.label) )
           metrics ) ]

let results_table () =
  let ready = Option.is_some (Settings_llm.configuration ()) in
  let rows =
    List.sort (fun a b -> Int.compare b.submission.id a.submission.id) !files
  in
  div
    ~a:[a_class ["card"; "p-3"; "mb-3"]]
    [ h2 ~a:[a_class ["h5"]] [txt "LLM evaluation"]
    ; ( if !reevaluation_notice = "" then div []
        else
          p
            ~a:[a_class ["alert"; "alert-info"]; a_aria "live" ["polite"]]
            [txt !reevaluation_notice] )
    ; p
        ~a:[a_class ["text-muted"]]
        [ txt "Configure the provider and prompt in "
        ; a ~a:[a_href "#settings-llm"] [txt "LLM settings"]
        ; txt ". Evaluation sends code only when requested." ]
    ; div
        ~a:[a_class ["table-responsive"]]
        [ table
            ~a:[a_class ["table"; "table-striped"]]
            ~thead:
              (thead
                 [ tr
                     [ th [txt "User"]
                     ; th [txt "Submission / file"]
                     ; th [txt "Problem"]
                     ; th [txt "Distance"]
                     ; th [txt "Judge verdict"]
                     ; th [txt "LLM evaluation"]
                     ; th [txt "Action"] ] ] )
            ( if rows = [] then
                [ tr
                    [ td
                        ~a:[a_colspan 7]
                        [txt "Analyze source files to populate this table."]
                    ] ]
              else
                List.map
                  (fun entry ->
                    let key = (entry.submission.id, entry.filename) in
                    let result =
                      List.find_opt
                        (fun r ->
                          (r.entry.submission.id, r.entry.filename) = key )
                        !evaluations
                    in
                    tr
                      [ td
                          [ txt
                              ( match entry.submission.owner_id with
                              | Some id ->
                                  Option.value
                                    ~default:"Username unavailable"
                                    (Hashtbl.find_opt usernames id)
                              | None -> "Username unavailable" ) ]
                      ; td
                          [ txt
                              (Printf.sprintf "#%d / %s" entry.submission.id
                                 entry.filename ) ]
                      ; td [txt (problem_code entry.submission.problem_id)]
                      ; td
                          [ txt
                              ( match
                                  (entry.distance, entry.relative_distance)
                                with
                              | Some d, Some relative ->
                                  Printf.sprintf "%d %s (%.2f%%)" d
                                    !selected_metric.unit_name relative
                              | _ -> "-" ) ]
                      ; td
                          [ txt
                              (I18n.submission_status entry.submission.status)
                          ]
                      ; td
                          ( match result with
                          | None -> [txt "Not evaluated"]
                          | Some r ->
                              [ span
                                  ~a:
                                    [ a_class
                                        ( if r.error then ["text-danger"]
                                          else [] ) ]
                                  [txt r.response] ] )
                      ; td
                          [ div
                              ~a:[a_class ["d-flex"; "gap-2"]]
                              ( button
                                  ~a:
                                    ( [ a_class
                                          [ "btn"
                                          ; "btn-sm"
                                          ; "btn-outline-primary" ]
                                      ; a_title "Evaluate with LLM"
                                      ; a_aria "label" ["Evaluate with LLM"]
                                      ; a_onclick (fun _ ->
                                            evaluate entry ; false ) ]
                                    @
                                    if (not ready) || !evaluating <> None
                                    then [a_disabled ()]
                                    else [] )
                                  [Components.Icons.robot_icon ()]
                              :: button
                                   ~a:
                                     ( [ a_class
                                           [ "btn"
                                           ; "btn-sm"
                                           ; "btn-outline-warning" ]
                                       ; a_title
                                           (I18n.t "submissions_reevaluate")
                                       ; a_aria "label"
                                           [I18n.t "submissions_reevaluate"]
                                       ; a_onclick (fun _ ->
                                             request_reevaluation
                                               entry.submission.id ;
                                             false ) ]
                                     @
                                     if !reevaluating <> None then
                                       [a_disabled ()]
                                     else [] )
                                   [ Components.Icons.reeval_icon
                                       ~a:
                                         ( if
                                             !reevaluating
                                             = Some entry.submission.id
                                           then ["spin"]
                                           else [] )
                                       () ]
                              :: Option.to_list
                                   (Components.Submissions_list_details
                                    .source_artifacts_action entry.submission )
                              ) ] ] )
                  rows ) ] ]

let format_contest_time value =
  let timestamp = Js.Unsafe.global##.Date##parse (Js.string value) in
  if Float.is_nan (Js.float_of_number timestamp) then value
  else
    let date = new%js Js.date_fromTimeValue timestamp in
    let offset = -date##getTimezoneOffset in
    Printf.sprintf "%s (UTC%s%02d:%02d)"
      (Js.to_string date##toLocaleString)
      (if offset < 0 then "-" else "+")
      (abs offset / 60)
      (abs offset mod 60)

let content contest_id =
  if !contest <> contest_id then (
    contest := contest_id ;
    contest_details := None ;
    load_contest_details contest_id ;
    submissions := [] ;
    files := [] ;
    evaluations := [] ;
    analyzing := false ;
    evaluating := None ;
    selected_user := None ;
    Hashtbl.clear usernames ;
    Hashtbl.clear problem_codes ;
    message := "" ;
    load ~on_loaded:(fun () -> analyze contest_id) contest_id ) ;
  let contest_title =
    match !contest_details with
    | Some details -> details.title
    | None -> string_of_int contest_id
  in
  main
    ~a:[a_class ["panel"; "flex-grow-1"; "judge-board"]]
    [ section
        ~a:
          [ a_class
              ["panel-section"; "container-fluid"; "py-3"; "px-3"; "px-lg-4"]
          ]
        [ div
            ~a:
              [ a_class
                  [ "d-flex"
                  ; "flex-wrap"
                  ; "justify-content-between"
                  ; "align-items-center"
                  ; "gap-2"
                  ; "mb-3" ] ]
            [ h1 ~a:[a_class ["h3"; "mb-0"]] [txt "Judge board"]
            ; div
                ~a:[a_class ["d-flex"; "gap-2"]]
                [ button
                    ~a:
                      ( [ a_class ["btn"; "btn-outline-secondary"]
                        ; a_onclick (fun _ ->
                              load
                                ~on_loaded:(fun () -> analyze contest_id)
                                contest_id ;
                              rerender () ;
                              false ) ]
                      @
                      if !loading || !analyzing then [a_disabled ()] else []
                      )
                    [txt "Refresh"]
                ; button
                    ~a:
                      ( [ a_class ["btn"; "btn-primary"]
                        ; a_onclick (fun _ -> analyze contest_id ; false) ]
                      @
                      if !analyzing || !loading then [a_disabled ()] else []
                      )
                    [ txt
                        ( if !analyzing then "Analyzing..."
                          else "Recalculate file distances" ) ] ] ]
        ; div
            ~a:[a_class ["card"; "p-3"; "mb-3"]]
            ( match !contest_details with
            | None ->
                [ p
                    ~a:[a_class ["text-muted"; "mb-0"]]
                    [ txt
                        (Printf.sprintf "Loading contest #%d details..."
                           contest_id ) ] ]
            | Some details ->
                let status_label, status_class =
                  match details.status with
                  | Api.Openapi.Running -> ("Running", "text-bg-success")
                  | Api.Openapi.Upcoming -> ("Upcoming", "text-bg-warning")
                  | Api.Openapi.Finished -> ("Finished", "text-bg-secondary")
                in
                [ div
                    ~a:
                      [ a_class
                          [ "d-flex"
                          ; "flex-wrap"
                          ; "align-items-center"
                          ; "gap-2" ] ]
                    [ h2
                        ~a:[a_class ["h5"; "mb-0"]]
                        [ txt
                            (Printf.sprintf "%s | #%d" details.title
                               details.id ) ]
                    ; span
                        ~a:[a_class ["badge"; status_class]]
                        [txt status_label] ] ]
                @ ( match details.description with
                  | Some description when description <> "" ->
                      [ p
                          ~a:[a_class ["text-muted"; "mt-2"; "mb-0"]]
                          [txt description] ]
                  | _ -> [] )
                @ [ div
                      ~a:[a_class ["judge-contest-dates"]]
                      [ div
                          [ span
                              ~a:[a_class ["text-muted"; "small"]]
                              [txt "Starts"]
                          ; time
                              ~a:[a_datetime details.start_time]
                              [txt (format_contest_time details.start_time)]
                          ]
                      ; div
                          [ span
                              ~a:[a_class ["text-muted"; "small"]]
                              [txt "Ends"]
                          ; time
                              ~a:[a_datetime details.end_time]
                              [txt (format_contest_time details.end_time)] ]
                      ] ] )
        ; (if !loading then p [txt "Loading submissions..."] else div [])
        ; ( if !message <> "" then
              p ~a:[a_class ["text-muted"]] [txt !message]
            else div [] )
        ; ( if !loading then div []
            else
              histogram ~show_users:true
                ~title:
                  ("Verdicts for Each Problem in Contest " ^ contest_title)
                !submissions )
        ; ( if !loading then div []
            else
              div
                [ user_selector ~on_select:(fun () -> analyze contest_id) ()
                ; metric_selector
                    ~on_select:(fun () -> analyze contest_id)
                    ()
                ; ( if
                      List.exists
                        (fun (sub : Api.Openapi.submission) ->
                          match sub.owner_id with
                          | None -> false
                          | Some id -> not (Hashtbl.mem usernames id) )
                        !submissions
                    then
                      p
                        ~a:[a_class ["text-warning"]]
                        [ txt
                            "Some usernames are unavailable; those \
                             individual views require access to \
                             /admin/users." ]
                    else div [] ) ] )
        ; ( if !loading then div []
            else
              div
                ( ( match !selected_user with
                    | None -> []
                    | Some id ->
                        [ histogram
                            ~title:
                              ( "Verdicts per Problem for "
                              ^ Option.value ~default:"User"
                                  (Hashtbl.find_opt usernames id) )
                            (visible_submissions ()) ] )
                @ [distance_plot (); results_table ()] ) ) ] ]

let render () =
  if not (Helpers.is_judge_or_admin ()) then (
    Settings_llm.clear_api_key () ;
    [ div
        ~a:[a_class ["panel"; "p-4"]]
        [h1 [txt "Judge board"]; p [txt "Judge or admin access required."]]
    ] )
  else
    let body = content (Helpers.get_current_contest_id ()) in
    match Helpers.layout () with
    | Helpers.Mobile ->
        [ div
            ~a:[a_class ["w-100"]]
            [Components.Sidebar.sidebar ~mobile:true (); body] ]
    | Helpers.Normal ->
        [ Components.Sidebar.sidebar ~wide:false ()
        ; div ~a:[a_class ["flex-grow-1"; "judge-board"]] [body] ]
    | Helpers.Wide ->
        [ Components.Sidebar.sidebar ()
        ; div ~a:[a_class ["flex-grow-1"; "judge-board"]] [body] ]
