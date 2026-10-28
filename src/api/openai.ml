open Js_of_ocaml_lwt
open Lwt.Infix

let models_url endpoint =
  let url = String.trim endpoint in
  let url =
    if Astring.String.is_suffix ~affix:"/" url then
      String.sub url 0 (String.length url - 1)
    else url
  in
  let suffix = "/chat/completions" in
  if Astring.String.is_suffix ~affix:suffix url then
    Some
      (String.sub url 0 (String.length url - String.length suffix) ^ "/models")
  else None

let list_models ~endpoint ~api_key =
  match models_url endpoint with
  | None -> Lwt.fail (Failure "Endpoint must end in /chat/completions.")
  | Some url ->
      XmlHttpRequest.perform_raw_url
        ~headers:[("Authorization", "Bearer " ^ api_key)] url
      >|= fun response ->
      if response.code < 200 || response.code >= 300 then
        failwith (Printf.sprintf "Provider returned HTTP %d." response.code) ;
      try
        Yojson.Safe.from_string response.content
        |> Yojson.Safe.Util.member "data"
        |> Yojson.Safe.Util.to_list
        |> List.map (fun item ->
               Yojson.Safe.Util.(item |> member "id" |> to_string) )
        |> List.sort_uniq String.compare
      with _ -> failwith "Provider response did not include model IDs."

let chat_completion ~endpoint ~api_key ~model ~messages =
  let body =
    `Assoc
      [ ("model", `String model)
      ; ( "messages"
        , `List
            (List.map
               (fun (role, content) ->
                 `Assoc
                   [("role", `String role); ("content", `String content)] )
               messages ) ) ]
    |> Yojson.Safe.to_string
  in
  XmlHttpRequest.perform_raw_url ~override_method:`POST
    ~headers:
      [ ("Content-Type", "application/json")
      ; ("Authorization", "Bearer " ^ api_key) ]
    ~contents:(`String body) endpoint
  >|= fun response ->
  if response.code < 200 || response.code >= 300 then
    failwith (Printf.sprintf "Provider returned HTTP %d." response.code) ;
  try
    let json = Yojson.Safe.from_string response.content in
    Yojson.Safe.Util.(json |> member "choices" |> to_list)
    |> List.hd
    |> Yojson.Safe.Util.member "message"
    |> Yojson.Safe.Util.member "content"
    |> Yojson.Safe.Util.to_string
  with _ -> failwith "Provider response did not include message content."
