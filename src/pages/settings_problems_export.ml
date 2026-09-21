open Js_of_ocaml

let trigger_download filename content =
  let blob =
    File.blob_from_any ~contentType:"application/json;charset=utf-8"
      [`string content]
  in
  let url_obj = Js.Unsafe.coerce Dom_html.window##._URL in
  let object_url =
    Js.Unsafe.meth_call url_obj "createObjectURL"
      [|Js.Unsafe.inject blob|]
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
       [|Js.Unsafe.inject (Js.string object_url)|])

let export_testcases ~problem_id (testcases : Api.Openapi.testCase list) =
  let json =
    `Assoc
      [ ("problem_id", `Int problem_id)
      ; ( "test_cases"
        , `List
            (List.map
               (fun (testcase : Api.Openapi.testCase) ->
                 `Assoc
                   [ ("input", `String testcase.input)
                   ; ("output", `String testcase.output)
                   ; ("is_sample", `Bool testcase.is_sample) ] )
               testcases) ) ]
  in
  let filename = Printf.sprintf "problem-%d-test-cases.json" problem_id in
  trigger_download filename (Yojson.Safe.pretty_to_string json)
