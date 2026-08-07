open Js_of_ocaml
open Js_of_ocaml_lwt
open Lwt.Infix

let decrypt_cipher cipher_hex =
  let len = String.length cipher_hex / 2 in
  let buf = Bytes.create len in
  for i = 0 to len - 1 do
    let byte = int_of_string ("0x" ^ String.sub cipher_hex (2 * i) 2) in
    Bytes.set buf i (Char.chr (byte lxor 27))
  done ;
  Bytes.to_string buf

let get_base_url () : string =
  let v = Js.Unsafe.get Js.Unsafe.global (Js.string "__BASE_API_URL__") in
  try
    let cipher_hex = Js.to_string (Obj.magic v) in
    decrypt_cipher cipher_hex
  with _ -> "http://localhost:8001"

let base_url = get_base_url ()

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
  >>= fun resp ->
  Console.console##log (Js.string ("Response: " ^ resp.content)) ;
  Lwt.return (Yojson.Safe.from_string resp.content, resp.code)

let post_json url body =
  XmlHttpRequest.perform_raw_url ~override_method:`POST ~headers:(headers ())
    ~contents:(`String body) url
  >>= fun resp -> Lwt.return (Yojson.Safe.from_string resp.content, resp.code)

let login username password =
  let body =
    Printf.sprintf {|{"username":"%s","password":"%s"}|} username password
  in
  post_json (base_url ^ "/auth/login") body

let get_users () = fetch_json (base_url ^ "/users")

let get_contests () = fetch_json (base_url ^ "/contests")

let submit_solution json_obj =
  post_json (base_url ^ "/submissions") (Yojson.Safe.to_string json_obj)

let get_scoreboard contest_id =
  fetch_json (Printf.sprintf "%s/contests/%d/scoreboard" base_url contest_id)

let verify_token () =
  XmlHttpRequest.perform_raw_url ~headers:(headers ())
    (base_url ^ "/contests")
  >>= fun resp -> Lwt.return (resp.code = 200)

let get_problems contest_id =
  fetch_json (Printf.sprintf "%s/contests/%d/problems" base_url contest_id)

(* --- admin config helpers --- *)
let put_json url body =
  XmlHttpRequest.perform_raw_url ~override_method:`PUT ~headers:(headers ())
    ~contents:(`String body) url
  >>= fun resp -> Lwt.return (Yojson.Safe.from_string resp.content, resp.code)

let delete_json url =
  XmlHttpRequest.perform_raw_url ~override_method:`DELETE
    ~headers:(headers ()) url
  >>= fun resp -> Lwt.return resp.code

let post_admin_user json_obj =
  post_json (base_url ^ "/admin/users") (Yojson.Basic.to_string json_obj)

let get_admin_users () = fetch_json (base_url ^ "/admin/users")

let put_admin_user user_id json_obj =
  put_json
    (Printf.sprintf "%s/admin/users/%d" base_url user_id)
    (Yojson.Basic.to_string json_obj)

let delete_admin_user user_id =
  delete_json (Printf.sprintf "%s/admin/users/%d" base_url user_id)

let get_config () = fetch_json (base_url ^ "/admin/yodac/config")

let put_config json_obj =
  put_json
    (base_url ^ "/admin/yodac/config")
    (Yojson.Basic.to_string json_obj)

let get_config_history () =
  fetch_json (base_url ^ "/admin/yodac/config/history")

let get_admin_stats () = fetch_json (base_url ^ "/admin/stats")

(* --- Problem CRUD helpers --- *)

let post_problem contest_id body =
  post_json
    (Printf.sprintf "%s/contests/%d/problems" base_url contest_id)
    body

let put_problem contest_id problem_id body =
  put_json
    (Printf.sprintf "%s/contests/%d/problems/%d" base_url contest_id
       problem_id )
    body

let delete_problem problem_id =
  delete_json (Printf.sprintf "%s/admin/problems/%d" base_url problem_id)

(* --- Submission re-evaluate helpers --- *)

let re_evaluate_submission submission_id =
  post_json
    (Printf.sprintf "%s/admin/submissions/%d/reevaluate" base_url
       submission_id )
    "{}"

(* --- Testcase helpers --- *)

let get_testcases contest_id problem_id =
  fetch_json
    (Printf.sprintf "%s/contests/%d/problems/%d/testcases" base_url
       contest_id problem_id )

let post_testcase contest_id problem_id body =
  post_json
    (Printf.sprintf "%s/contests/%d/problems/%d/testcases" base_url
       contest_id problem_id )
    body

let delete_testcase contest_id problem_id testcase_id =
  delete_json
    (Printf.sprintf "%s/contests/%d/problems/%d/testcases/%d" base_url
       contest_id problem_id testcase_id )

(* --- Import helpers --- *)

let create_problem_with_source contest_id ~code ~title ~time_limit_ms
    ~memory_limit_mb ~description ~input_spec ~output_spec ~languages
    ~source_artifacts =
  let body =
    match source_artifacts with
    | Some arts ->
        Openapi.ProblemCreateRequest.create ~code ~title ~description
          ~input_spec ~output_spec ~time_limit_ms ~memory_limit_mb ~languages
          ~source_artifacts:arts ()
        |> Openapi.ProblemCreateRequest.to_json
    | None ->
        Openapi.ProblemCreateRequest.create ~code ~title ~description
          ~input_spec ~output_spec ~languages ~time_limit_ms ~memory_limit_mb
          ()
        |> Openapi.ProblemCreateRequest.to_json
  in
  post_json
    (Printf.sprintf "%s/contests/%d/problems" base_url contest_id)
    body

let update_problem_source contest_id problem_id source_artifacts =
  let body =
    Openapi.ProblemUpdateRequest.create ~source_artifacts ()
    |> Openapi.ProblemUpdateRequest.to_json
  in
  put_json
    (Printf.sprintf "%s/contests/%d/problems/%d" base_url contest_id
       problem_id )
    body
