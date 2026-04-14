open Js_of_ocaml
open Js_of_ocaml_lwt
open Lwt.Infix

let base_url = "http://localhost:4000"

let get_local_storage_item key =
  match Js.Optdef.to_option Dom_html.window##.localStorage with
  | None -> None
  | Some storage -> Js.Opt.to_option (storage##getItem (Js.string key))

let auth_token () =
  match get_local_storage_item "token" with
  | Some t -> t
  | None -> Js.string ""

let headers () =
  let token = Js.to_string (auth_token ()) in
  let h = [("Content-Type", "application/json")] in
  if token <> "" then ("Authorization", "Bearer " ^ token) :: h else h

let fetch_json url =
  XmlHttpRequest.perform_raw_url ~headers:(headers ()) url
  >>= fun resp -> Lwt.return (Json.unsafe_input (Js.string resp.content))

let post_json url body =
  XmlHttpRequest.perform_raw_url ~override_method:`POST ~headers:(headers ())
    ~contents:(`String body) url
  >>= fun resp -> Lwt.return (Json.unsafe_input (Js.string resp.content))

let login username password =
  let body =
    Printf.sprintf {|{"username":"%s","password":"%s"}|} username password
  in
  post_json (base_url ^ "/auth/login") body

let get_users () = fetch_json (base_url ^ "/users")

let get_contests () = fetch_json (base_url ^ "/contests")

let get_problems contest_id =
  fetch_json (Printf.sprintf "%s/contests/%d/problems" base_url contest_id)

let submit_solution contest_id problem_id language source_code =
  let body =
    Printf.sprintf
      {|{"contest_id":%d,"problem_id":%d,"language":"%s","source_code":"%s"}|}
      contest_id problem_id language source_code
  in
  post_json (base_url ^ "/submissions") body

let get_scoreboard contest_id =
  fetch_json (Printf.sprintf "%s/contests/%d/scoreboard" base_url contest_id)
