open Js_of_ocaml

let trigger_download filename content =
  let blob =
    File.blob_from_any ~contentType:"application/json;charset=utf-8"
      [`string content]
  in
  let url_obj = Js.Unsafe.coerce Dom_html.window##._URL in
  let object_url =
    Js.Unsafe.meth_call url_obj "createObjectURL" [|Js.Unsafe.inject blob|]
    |> Js.Unsafe.coerce |> Js.to_string
  in
  let anchor = Dom_html.createA Dom_html.document in
  anchor##.href := Js.string object_url ;
  anchor##.download := Js.string filename ;
  anchor##.style##.display := Js.string "none" ;
  ignore (Dom.appendChild Dom_html.document##.body (Js.Unsafe.coerce anchor)) ;
  anchor##click ;
  ignore (Js.Unsafe.meth_call (Js.Unsafe.coerce anchor) "remove" [||]) ;
  ignore
    (Js.Unsafe.meth_call url_obj "revokeObjectURL"
       [|Js.Unsafe.inject (Js.string object_url)|] )

let export_problem ~(testcases : Api.Openapi.testCase list)
    ~(source_artifacts : Api.Openapi.sourceArtifact list)
    (problem : Api.Openapi.problem) =
  let filename =
    match problem.id with
    | Some problem_id -> Printf.sprintf "problem-%d.json" problem_id
    | None -> "problem.json"
  in
  let problem_json = Api.Openapi.Problem.to_yojson problem in
  let json =
    match problem_json with
    | `Assoc fields ->
        `Assoc
          ( fields
          @ [ ( "test_cases"
              , `List (List.map Api.Openapi.TestCase.to_yojson testcases) )
            ; ( "source_artifacts"
              , Api.Openapi.SourceArtifacts.to_yojson source_artifacts ) ] )
    | _ -> problem_json
  in
  trigger_download filename (Yojson.Safe.pretty_to_string json)
