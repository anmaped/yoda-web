open Js_of_ocaml

let key_problem_id = "yoda-state-current-problem-id"

let key_problem_description = "yoda-state-current-problem-description"

let key_problem_language = "yoda-state-current-problem-language"

let key_viewed_problem_ids = "yoda-state-viewed-problem-ids"

let parse_problem_id value = try Some (int_of_string value) with _ -> None

(** Returns the ID of the currently selected problem *)
let get_selected_problem_id () =
  match Helpers.get_local_variable key_problem_id with
  | Some id -> parse_problem_id (Js.to_string id)
  | None -> None

let set_current_problem_id id =
  Helpers.set_local_variable key_problem_id (string_of_int id)

let get_viewed_problem_ids () =
  match Helpers.get_local_variable key_viewed_problem_ids with
  | Some value -> (
    try
      Yojson.Basic.from_string (Js.to_string value)
      |> Yojson.Basic.Util.to_list
      |> List.filter_map (fun json ->
          try Some (Yojson.Basic.Util.to_int json) with _ -> None )
    with _ -> [] )
  | None -> []

let mark_problem_viewed id =
  let ids = get_viewed_problem_ids () in
  if not (List.mem id ids) then
    let value =
      `List (List.map (fun viewed_id -> `Int viewed_id) (id :: ids))
      |> Yojson.Basic.to_string
    in
    Helpers.set_local_variable key_viewed_problem_ids value

let get_selected_problem_language () =
  match Helpers.get_local_variable key_problem_language with
  | Some language -> Some (Js.to_string language)
  | None -> None

let set_current_problem_language language =
  Helpers.set_local_variable key_problem_language language

let get_current_problem_description () =
  match Helpers.get_local_variable key_problem_description with
  | Some desc -> Js.to_string desc
  | None -> ""

let set_current_problem_description desc =
  Helpers.set_local_variable key_problem_description desc
