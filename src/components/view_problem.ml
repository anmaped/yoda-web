open Js_of_ocaml
open Js_of_ocaml_tyxml
open Tyxml_js.Html
open Lwt.Infix

let problem_view (problem : Api.Openapi.problem) =
  section
    ~a:[a_class ["panel-section"]]
    [ h2 [txt (problem.code ^ ". " ^ problem.title)]
    ; p
        [ b [txt (I18n.t "problem_time_limit"); txt ": "]
        ; txt (Printf.sprintf "%d ms" problem.time_limit_ms) ]
    ; p
        [ b [txt (I18n.t "problem_memory_limit"); txt ": "]
        ; txt (Printf.sprintf "%d MB" problem.memory_limit_mb) ]
    ; h3 [txt (I18n.t "problem_description")]
    ; p [txt problem.description]
    ; h3 [txt (I18n.t "problem_input")]
    ; p [txt problem.input_spec]
    ; h3 [txt (I18n.t "problem_output")]
    ; p [txt problem.output_spec] ]

let content ~contest_id ~problem_id () =
  let subcontainer = div ~a:[a_class ["card-header"]] [] in
  let container =
    section
      ~a:[a_class ["panel-section"; "container"; "py-3"]]
      [div ~a:[a_class ["card"; "shadow-sm"]] [subcontainer]]
  in
  Lwt.async (fun () ->
      Api.Helpers.get_problems contest_id
      >>= fun (resp, status) ->
      if status <> 200 then (
        Console.console##log
          (Js.string (Printf.sprintf "Failed to fetch problems: %d" status)) ;
        Lwt.return_unit )
      else
        let problems =
          Api.Openapi.ContestsContestsidProblemsGetResponse2.of_yojson resp
        in
        ( match
            List.find_opt
              (fun (p : Api.Openapi.problem) -> p.code = problem_id)
              problems
          with
        | None ->
            Dom.appendChild
              (Tyxml_js.To_dom.of_div subcontainer)
              (Tyxml_js.To_dom.of_p (p [txt (I18n.t "problem_not_found")]))
        | Some problem ->
            Dom.appendChild
              (Tyxml_js.To_dom.of_div subcontainer)
              (Tyxml_js.To_dom.of_section (problem_view problem)) ) ;
        Lwt.return_unit ) ;
  container
