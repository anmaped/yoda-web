open Js_of_ocaml_tyxml
open Tyxml_js.Html

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
