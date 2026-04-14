open Js_of_ocaml
open Js_of_ocaml_tyxml
open Tyxml_js.Html

let get_session_contest_id () =
  Js.Optdef.case
    Dom_html.window##.sessionStorage
    (fun () -> "")
    (fun storage ->
      Js.Opt.case
        (storage##getItem (Js.string "contest_id"))
        (fun () -> "")
        Js.to_string )

let render ?(problem_id = "") () =
  let contest_id =
    try int_of_string (get_session_contest_id ())
    with Failure _ -> failwith "Invalid contest_id in sessionStorage!"
  in
  Components.Problem_list.render ~contest_id ~problem_id ()
