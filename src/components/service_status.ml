open Js_of_ocaml
open Js_of_ocaml_lwt
open Js_of_ocaml_tyxml
open Lwt.Infix

type state = Checking | Available | Maintenance of string | Unavailable

let state = ref Checking

let status_interval_seconds = 15

let seconds_until_check = ref None

let is_available () = !state = Available

let retry_text () =
  match !seconds_until_check with
  | Some seconds ->
      I18n.interpolate
        (I18n.t "status_retry_countdown")
        [string_of_int seconds]
  | None -> I18n.t "status_retrying"

let retry_progress () =
  match !seconds_until_check with
  | Some seconds -> 100 * seconds / status_interval_seconds
  | None -> 0

let render () =
  let open Tyxml_js.Html in
  let title, description =
    match !state with
    | Checking -> ("status_checking_title", "status_checking_description")
    | Maintenance _ ->
        ("status_maintenance_title", "status_maintenance_description")
    | Unavailable ->
        ("status_unavailable_title", "status_unavailable_description")
    | Available -> assert false
  in
  let description =
    match !state with
    | Maintenance message when String.trim message <> "" -> message
    | _ -> I18n.t description
  in
  div
    ~a:[a_class ["service-status"; "w-100"]]
    [ div
        ~a:[a_class ["service-status-card"; "text-center"]]
        ( [ img ~src:Blobs.yoda_logo_url ~alt:"Yoda"
              ~a:[a_class ["service-status-logo"; "mb-4"]]
              ()
          ; h1 ~a:[a_class ["h2"; "mb-3"]] [txt (I18n.t title)]
          ; p ~a:[a_class ["text-body-secondary"; "mb-2"]] [txt description]
          ]
        @
        match !state with
        | Maintenance _ | Unavailable ->
            [ div
                ~a:[a_class ["service-status-retry"]]
                [ p
                    ~a:
                      [ a_id "service-status-countdown"
                      ; a_class ["service-status-countdown"; "mb-2"] ]
                    [txt (retry_text ())]
                ; div
                    ~a:[a_class ["service-status-progress"]]
                    [ div
                        ~a:
                          [ a_id "service-status-progress-fill"
                          ; a_class ["service-status-progress-fill"]
                          ; a_style
                              (Printf.sprintf "width: %d%%"
                                 (retry_progress ()) ) ]
                        [] ] ] ]
        | Checking | Available -> [] ) ]

let update_retry () =
  ( match
      Js.Opt.to_option
        (Dom_html.document##getElementById
           (Js.string "service-status-countdown") )
    with
  | Some element ->
      element##.textContent := Js.some (Js.string (retry_text ()))
  | None -> () ) ;
  match
    Js.Opt.to_option
      (Dom_html.document##getElementById
         (Js.string "service-status-progress-fill") )
  with
  | Some element ->
      element##.style##.width
      := Js.string (Printf.sprintf "%d%%" (retry_progress ()))
  | None -> ()

let get_status () =
  XmlHttpRequest.perform_raw_url (Api.Helpers.base_url ^ "/status")
  >>= fun resp ->
  if resp.code <> 200 && resp.code <> 503 then
    failwith "Failed to fetch service status" ;
  let response = Api.Openapi.Status.of_json resp.content in
  match response.status with
  | Api.Openapi.Maintenance -> Lwt.return (Maintenance response.message)
  | Api.Openapi.Ok when resp.code = 200 -> Lwt.return Available
  | Api.Openapi.Ok -> failwith "Invalid service status response"

let start ~on_change () =
  let rec check_status () =
    seconds_until_check := None ;
    update_retry () ;
    Lwt.catch get_status (fun _ -> Lwt.return Unavailable)
    >>= fun current ->
    seconds_until_check := Some status_interval_seconds ;
    if current <> !state then (
      state := current ;
      on_change () ) ;
    update_retry () ;
    wait_for_check status_interval_seconds
  and wait_for_check seconds =
    Lwt_js.sleep 1.0
    >>= fun () ->
    if seconds = 1 then check_status ()
    else (
      seconds_until_check := Some (seconds - 1) ;
      update_retry () ;
      wait_for_check (seconds - 1) )
  in
  Lwt.async check_status
