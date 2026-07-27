open Lwt.Infix
open Js_of_ocaml_tyxml
open Tyxml_js.Html

let stats_loaded : bool ref = ref false

let stats_loading : bool ref = ref false

let stats_error : string option ref = ref None

let stats_data : Api.Openapi.adminStatsResponse option ref = ref None

let metric_row label_text value_text =
  tr [th [txt label_text]; td ~a:[a_class ["text-end"]] [txt value_text]]

let render_metric_table rows =
  table ~a:[a_class ["table"; "table-sm"; "mb-0"]] rows

let load_stats () : unit Lwt.t =
  if !stats_loading then Lwt.return ()
  else (
    stats_loading := true ;
    stats_error := None ;
    Api.Helpers.get_admin_stats ()
    >>= fun (json, code) ->
    stats_loading := false ;
    if code = 200 then (
      try
        let now_ms =
          Js_of_ocaml.Js.float_of_number
            (new%js Js_of_ocaml.Js.date_now)##getTime
        in
        let parsed = Api.Openapi.adminStatsResponse_of_yojson json in
        let req_total = parsed.yodab.yodab_requests_total in
        let queue_total =
          Option.value ~default:0 parsed.yodac.queued_jobs_total
        in
        Settings_stats_graphs.add_sample ~req_total ~queue_total ~now_ms ;
        stats_data := Some parsed ;
        stats_loaded := true ;
        stats_error := None ;
        Helpers.trigger_render () ;
        Lwt.return ()
      with exn ->
        stats_error :=
          Some
            (I18n.interpolate
               (I18n.t "stats_parse_error")
               [Printexc.to_string exn] ) ;
        Helpers.trigger_render () ;
        Lwt.return () )
    else (
      stats_error :=
        Some
          (I18n.interpolate
             (I18n.t "stats_error_prefix")
             [string_of_int code] ) ;
      Helpers.trigger_render () ;
      Lwt.return () ) )

let refresh_button () =
  button
    ~a:
      ( [ a_class ["btn"; "btn-outline-secondary"; "btn-sm"]
        ; a_onclick (fun _ ->
              ignore (load_stats ()) ;
              false ) ]
      @ if !stats_loading then [a_disabled ()] else [] )
    [txt (I18n.t "stats_refresh_btn")]

let render_stats_content (stats : Api.Openapi.adminStatsResponse) =
  let contributors =
    if stats.contributors = [] then "-"
    else String.concat ", " stats.contributors
  in
  let yodab_rows =
    [ metric_row
        (I18n.t "stats_requests_total")
        (string_of_int stats.yodab.yodab_requests_total)
    ; metric_row
        (I18n.t "stats_requests_per_minute")
        (string_of_int stats.yodab.yodab_requests_per_minute)
    ; metric_row
        (I18n.t "stats_submissions_total")
        (string_of_int stats.yodab.submissions_total)
    ; metric_row
        (I18n.t "stats_submissions_per_minute")
        (string_of_int stats.yodab.submissions_per_minute) ]
  in
  let yodac_rows =
    [ metric_row
        (I18n.t "stats_queued_jobs_total")
        (string_of_int
           (Option.value ~default:0 stats.yodac.queued_jobs_total) )
    ; metric_row
        (I18n.t "stats_queued_jobs_per_minute")
        (string_of_int stats.yodac.queued_jobs_per_minute)
    ; metric_row
        (I18n.t "stats_processed_jobs_total")
        (string_of_int stats.yodac.processed_jobs_total)
    ; metric_row
        (I18n.t "stats_processed_jobs_per_minute")
        (string_of_int stats.yodac.processed_jobs_per_minute) ]
  in
  div
    [ Settings_helpers.section_card
        (I18n.t "stats_service_info")
        [ render_metric_table
            [ metric_row (I18n.t "stats_api_version") stats.api_version
            ; metric_row (I18n.t "stats_yoda_version") stats.yoda_version
            ; metric_row (I18n.t "stats_contributors") contributors ] ]
    ; Settings_helpers.section_card (I18n.t "stats_yodab")
        [ Settings_stats_graphs.render_line_graph
            ~label:(I18n.t "stats_requests_total" ^ " delta/s")
            ~values:(Settings_stats_graphs.requests_values ())
        ; render_metric_table yodab_rows ]
    ; Settings_helpers.section_card (I18n.t "stats_yodac")
        [ Settings_stats_graphs.render_line_graph
            ~label:(I18n.t "stats_queued_jobs_total" ^ " delta/s")
            ~values:(Settings_stats_graphs.queued_values ())
        ; render_metric_table yodac_rows ] ]

let render_stats_tab () =
  Settings_stats_graphs.start_polling
    ~is_loading:(fun () -> !stats_loading)
    ~load_stats ;
  if (not !stats_loaded) && not !stats_loading then ignore (load_stats ()) ;
  let content =
    match !stats_data with
    | Some stats -> render_stats_content stats
    | None when !stats_loading ->
        div
          ~a:[a_class ["alert"; "alert-info"]]
          [txt (I18n.t "stats_loading")]
    | None ->
        div
          ~a:[a_class ["alert"; "alert-warning"]]
          [txt (I18n.t "stats_empty")]
  in
  div
    [ div
        ~a:[a_class ["d-flex"; "justify-content-end"; "mb-3"]]
        [refresh_button ()]
    ; ( match !stats_error with
      | Some msg -> div ~a:[a_class ["alert"; "alert-danger"]] [txt msg]
      | None -> div [] )
    ; content ]
