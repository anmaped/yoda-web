open Js_of_ocaml

let zip_download_name problem_id =
  match problem_id with
  | Some pid -> Printf.sprintf "problem-%d-artifacts.zip" pid
  | None -> "artifacts.zip"

let trigger_blob_download filename blob =
  let url_obj = Js.Unsafe.coerce Dom_html.window##._URL in
  let object_url =
    Js.Unsafe.meth_call url_obj "createObjectURL" [|Js.Unsafe.inject blob|]
    |> Js.Unsafe.coerce |> Js.to_string
  in
  let anchor = Dom_html.createA Dom_html.document in
  anchor##.href := Js.string object_url ;
  anchor##.download := Js.string filename ;
  anchor##.style##.display := Js.string "none" ;
  let body = Dom_html.document##.body in
  ignore (Dom.appendChild body (Js.Unsafe.coerce anchor)) ;
  anchor##click ;
  ignore (Js.Unsafe.meth_call (Js.Unsafe.coerce anchor) "remove" [||]) ;
  ignore
    (Js.Unsafe.meth_call url_obj "revokeObjectURL"
       [|Js.Unsafe.inject (Js.string object_url)|] )

let download_all_files_as_zip ~problem_id files =
  if List.length files = 0 then ()
  else
    let zip = Js.Unsafe.new_obj (Js.Unsafe.pure_js_expr "JSZip") [||] in
    List.iter
      (fun (filename, content) ->
        ignore
          (Js.Unsafe.meth_call zip "file"
             [| Js.Unsafe.inject (Js.string filename)
              ; Js.Unsafe.inject (Js.string content)
             |] ) )
      files ;
    let options =
      Js.Unsafe.obj [|("type", Js.Unsafe.inject (Js.string "blob"))|]
    in
    let promise =
      Js.Unsafe.meth_call zip "generateAsync" [|Js.Unsafe.inject options|]
    in
    let on_success =
      Js.wrap_callback (fun blob ->
          trigger_blob_download (zip_download_name problem_id) blob )
    in
    let on_error =
      Js.wrap_callback (fun err ->
          Console.console##error
            (Js.string
               ("ZIP generation failed: " ^ Js.to_string (Js.Unsafe.coerce err))) )
    in
    ignore
      (Js.Unsafe.meth_call promise "then"
         [|Js.Unsafe.inject on_success; Js.Unsafe.inject on_error|] )