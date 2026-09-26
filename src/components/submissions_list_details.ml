open Js_of_ocaml_tyxml
open Tyxml_js.Html
open Lwt.Infix

type availability = Unavailable | Partial | Complete

let output_available (detail : Api.Openapi.submissionDetail) =
  match detail.output with Some _ -> true | None -> false

let availability (details : Api.Openapi.submissionDetails) =
  match details with
  | [] -> Unavailable
  | details when List.for_all output_available details -> Complete
  | _ -> Partial

let status_label status =
  match status with
  | "accepted" -> "Accepted"
  | "wrong_answer" -> "Wrong Answer"
  | "runtime_error" -> "Runtime Error"
  | "time_limit_exceeded" -> "Time Limit Exceeded"
  | "compilation_error" -> "Compilation Error"
  | value -> value

let format_time_ms ms = Printf.sprintf "%d ms" ms

let detail_row number (detail : Api.Openapi.submissionDetail) =
  let output_cells =
    match detail.output with
    | None -> [td [txt "Not available"]]
    | Some output ->
        [ td [pre [txt output.stdout]]
        ; td [pre [txt output.stderr]]
        ; td [txt (string_of_int output.return_code)] ]
  in
  tr
    ( [ td [txt (string_of_int number)]
      ; td [txt (status_label detail.status)]
      ; td [txt (format_time_ms detail.time_ms)] ]
    @ output_cells )

let details_modal submission_id details =
  let name = "submission-details-" ^ string_of_int submission_id in
  div
    ~a:[a_id name]
    [ div ~a:[a_class ["modal-backdrop"; "fade"; "show"]] []
    ; div
        ~a:[a_class ["modal"; "fade"; "show"]; a_style "display:block;"]
        [ div
            ~a:
              [ a_class
                  ["modal-dialog"; "modal-xl"; "modal-dialog-scrollable"] ]
            [ div
                ~a:[a_class ["modal-content"]]
                [ div
                    ~a:[a_class ["modal-header"]]
                    [ h5
                        ~a:[a_class ["modal-title"]]
                        [ txt
                            (Printf.sprintf "Submission #%d details"
                               submission_id ) ]
                    ; button
                        ~a:
                          [ a_class ["btn-close"]
                          ; a_onclick (fun _ ->
                                Helpers.remove_first_element_from_app
                                  ("#" ^ name) ;
                                false ) ]
                        [] ]
                ; div
                    ~a:[a_class ["modal-body"]]
                    [ table
                        ~a:[a_class ["table"; "table-sm"; "table-striped"]]
                        ( tr
                            [ th [txt "Test case"]
                            ; th [txt "Status"]
                            ; th [txt "Time"]
                            ; th [txt "Stdout"]
                            ; th [txt "Stderr"]
                            ; th [txt "Return code"] ]
                        :: List.mapi
                             (fun index detail ->
                               detail_row (index + 1) detail )
                             details ) ]
                ; div
                    ~a:[a_class ["modal-footer"]]
                    [ button
                        ~a:
                          [ a_class ["btn"; "btn-secondary"]
                          ; a_onclick (fun _ ->
                                Helpers.remove_first_element_from_app
                                  ("#" ^ name) ;
                                false ) ]
                        [txt (I18n.t "modal_close")] ] ] ] ] ]

let show submission_id details =
  Helpers.add_element_to_app (details_modal submission_id details)

let action submission_id (submission : Api.Openapi.submission) =
  match availability submission.details with
  | Unavailable -> None
  | Partial | Complete ->
      let classes, title =
        match availability submission.details with
        | Complete ->
            (["btn"; "btn-sm"; "btn-outline-success"], "View results")
        | Partial ->
            (["btn"; "btn-sm"; "btn-outline-warning"], "View partial results")
        | Unavailable -> ([], "")
      in
      Some
        (button
           ~a:
             [ a_class classes
             ; a_title title
             ; a_onclick (fun _ ->
                   show submission_id submission.details ;
                   false ) ]
           [Icons.table_icon ()] )

let source_artifacts_modal submission_id artifacts =
  let name = "submission-source-artifacts-" ^ string_of_int submission_id in
  div
    ~a:[a_id name]
    [ div ~a:[a_class ["modal-backdrop"; "fade"; "show"]] []
    ; div
        ~a:[a_class ["modal"; "fade"; "show"]; a_style "display:block;"]
        [ div
            ~a:
              [ a_class
                  ["modal-dialog"; "modal-xl"; "modal-dialog-scrollable"] ]
            [ div
                ~a:[a_class ["modal-content"]]
                [ div
                    ~a:[a_class ["modal-header"]]
                    [ h5
                        ~a:[a_class ["modal-title"]]
                        [ txt
                            (Printf.sprintf "Submission #%d source"
                               submission_id ) ]
                    ; button
                        ~a:
                          [ a_class ["btn-close"]
                          ; a_onclick (fun _ ->
                                Helpers.remove_first_element_from_app
                                  ("#" ^ name) ;
                                false ) ]
                        [] ]
                ; div
                    ~a:[a_class ["modal-body"]]
                    (List.map
                       (fun (artifact : Api.Openapi.sourceArtifact) ->
                         div
                           ~a:[a_class ["mb-3"]]
                           [ h6 [txt artifact.filename]
                           ; pre
                               ~a:[a_class ["bg-light"; "p-2"]]
                               [txt artifact.content] ] )
                       artifacts )
                ; div
                    ~a:[a_class ["modal-footer"]]
                    [ button
                        ~a:
                          [ a_class ["btn"; "btn-secondary"]
                          ; a_onclick (fun _ ->
                                Helpers.remove_first_element_from_app
                                  ("#" ^ name) ;
                                false ) ]
                        [txt (I18n.t "modal_close")] ] ] ] ] ]

let show_source_artifacts submission_id =
  let url =
    Printf.sprintf "%s/submissions/%d/details" Api.Helpers.base_url
      submission_id
  in
  Lwt.async (fun () ->
      Api.Helpers.fetch_json url
      >>= fun (resp, status) ->
      if status = 200 then
        let details = Api.Openapi.SubmissionFullDetails.of_yojson resp in
        Helpers.add_element_to_app
          (source_artifacts_modal submission_id details.source_artifacts)
      else () ;
      Lwt.return_unit )

let source_artifacts_action (submission : Api.Openapi.submission) =
  let classes owner =
    let color =
      if Helpers.is_judge_or_admin () then
        if owner then "btn-outline-success" else "btn-outline-warning"
      else "btn-outline-primary"
    in
    ["btn"; "btn-sm"; color]
  in
  match submission.owner with
  | Some true ->
      Some
        (button
           ~a:
             [ a_class (classes true)
             ; a_title "View submitted source"
             ; a_onclick (fun _ ->
                   show_source_artifacts submission.id ;
                   false ) ]
           [Icons.journal_code_icon ()] )
  | _ when Helpers.is_judge_or_admin () ->
      Some
        (button
           ~a:
             [ a_class (classes false)
             ; a_title "View submitted source"
             ; a_onclick (fun _ ->
                   show_source_artifacts submission.id ;
                   false ) ]
           [Icons.journal_code_icon ()] )
  | _ -> None
