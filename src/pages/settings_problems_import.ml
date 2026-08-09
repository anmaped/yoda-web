open Js_of_ocaml
open Js_of_ocaml_tyxml
open Js_of_ocaml_lwt
open Tyxml_js.Html
open Lwt.Infix

module RerenderFlag = struct
  let x = ref false

  let need_rerender () = !x

  let set_rerender () = x := true

  let unset_rerender () = x := false
end

let test_folder_names = ["test"; "tests"; "unittest"; "unittests"]

let tests_file_extensions = [".in"; ".out"; ".exp"]

let is_test_folder path =
  let parts = String.split_on_char '/' path in
  List.exists
    (fun part ->
      let lower = String.lowercase_ascii part in
      List.mem lower test_folder_names )
    parts

let is_hidden_folder_or_file path =
  let parts = String.split_on_char '/' path in
  List.exists (fun part -> String.length part > 0 && part.[0] = '.') parts

let is_test_file filename =
  let lower = String.lowercase_ascii filename in
  List.exists
    (fun ext -> Astring.String.is_suffix ~affix:ext lower)
    tests_file_extensions

(* folder name is a problem name *)
let folder_name_from_path path =
  let parts = String.split_on_char '/' path in
  match parts with
  | [] -> "unknown_problem"
  | [name] -> String.lowercase_ascii name
  | name :: _ -> String.lowercase_ascii name

(* folders names are problems names *)
let problem_names_from_paths paths =
  List.map folder_name_from_path paths |> List.sort_uniq String.compare

let read_file_as_arraybuffer (file : File.file Js.t) :
    Typed_array.arrayBuffer Js.t Lwt.t =
  let waiter, wakener = Lwt.wait () in
  let promise = Js.Unsafe.meth_call file "arrayBuffer" [||] in
  let on_success =
    Js.wrap_callback (fun value ->
        Lwt.wakeup_later wakener (Js.Unsafe.coerce value) )
  in
  let on_error =
    Js.wrap_callback (fun _ ->
        Lwt.wakeup_later_exn wakener (Failure "file_read_error") )
  in
  ignore
    (Js.Unsafe.meth_call promise "then"
       [|Js.Unsafe.inject on_success; Js.Unsafe.inject on_error|] ) ;
  waiter

let load_zip (buffer : Typed_array.arrayBuffer Js.t) =
  let jszip = Js.Unsafe.pure_js_expr "JSZip" in
  Js.Unsafe.meth_call jszip "loadAsync" [|Js.Unsafe.inject buffer|]

let extract_zip_contents (buffer : Typed_array.arrayBuffer Js.t) :
    (string * string) list Lwt.t =
  let waiter, wakener = Lwt.wait () in
  let promise = load_zip buffer in
  let on_success =
    Js.wrap_callback (fun zip ->
        let files = Js.Unsafe.get zip "files" in
        let keys =
          Js.Unsafe.fun_call
            (Js.Unsafe.pure_js_expr "Object.keys")
            [|Js.Unsafe.inject files|]
          |> Js.Unsafe.coerce
        in
        let length =
          Js.Unsafe.get keys "length"
          |> Js.Unsafe.coerce |> Js.to_int32 |> Int32.to_int
        in
        let rec read_files (i : int) acc =
          if i >= length then Lwt.wakeup_later wakener (List.rev acc)
          else
            let name =
              Js.Unsafe.get keys i |> Js.Unsafe.coerce |> Js.to_string
            in
            let file = Js.Unsafe.get files name in
            let content_promise =
              Js.Unsafe.meth_call file "async"
                [|Js.Unsafe.inject (Js.string "string")|]
            in
            let on_file =
              Js.wrap_callback (fun content ->
                  read_files (i + 1) ((name, Js.to_string content) :: acc) )
            in
            ignore
              (Js.Unsafe.meth_call content_promise "then"
                 [|Js.Unsafe.inject on_file|] )
        in
        read_files 0 [] )
  in
  let on_error =
    Js.wrap_callback (fun e ->
        Lwt.wakeup_later_exn wakener
          (Failure ("zip_extract_error: " ^ Js.to_string e)) )
  in
  ignore
    (Js.Unsafe.meth_call promise "then"
       [|Js.Unsafe.inject on_success; Js.Unsafe.inject on_error|] ) ;
  waiter

let get_test_case_files (files : (string * string) list) :
    (string * string) list =
  List.filter
    (fun (filename, _) ->
      is_test_folder (Filename.dirname filename) && is_test_file filename )
    files

(* Map file extensions to supported languages *)
let get_supported_languages (files : (string * string) list) : string list =
  (* Define the mapping from extensions to languages based on current
     configuration *)
  let extension_map =
    match !Settings_yodac.current_config with
    | None ->
        (* Fallback to default mappings if no config available *)
        [ (".ml", "ocaml")
        ; (".js", "javascript")
        ; (".py", "python")
        ; (".java", "java")
        ; (".cpp", "cpp")
        ; (".c", "c")
        ; (".rs", "rust")
        ; (".go", "go")
        ; (".ts", "typescript")
        ; (".php", "php")
        ; (".rb", "ruby")
        ; (".swift", "swift")
        ; (".kt", "kotlin")
        ; (".hs", "haskell")
        ; (".pl", "perl")
        ; (".sh", "shell")
        ; (".sql", "sql") ]
    | Some config ->
        let languages = config.config in
        List.map
          (fun (lang : Api.Openapi.YodacLanguageConfig.t) ->
            (lang.ext, lang.language) )
          languages
  in
  Console.console##log
    (Js.string
       (Printf.sprintf "Extension map: %s"
          (String.concat ", "
             (List.map (fun (ext, lang) -> ext ^ "->" ^ lang) extension_map) ) ) ) ;
  let rec find_languages acc filenames =
    match filenames with
    | [] -> acc
    | filename :: rest ->
        let ext = Filename.extension filename in
        Console.console##log
          (Js.string
             (Printf.sprintf "Checking file: %s, extension: %s" filename ext) ) ;
        let language =
          try
            (* Look for exact extension match *)
            List.assoc ext extension_map
          with Not_found -> (
            (* Try to find a match ignoring the leading dot *)
            try
              List.assoc
                (String.sub ext 1 (String.length ext - 1))
                extension_map
            with Not_found -> "" )
        in
        if language = "" then find_languages acc rest
        else find_languages (language :: acc) rest
  in
  let languages = find_languages [] (List.map fst files) in
  List.sort_uniq String.compare languages

(* Remove folders from files list - keeps only actual files *)
let remove_folders_from_files (files : (string * string) list) :
    (string * string) list =
  List.filter
    (fun (filename, _) ->
      (* Check if it's a folder by checking if filename ends with '/' or is
         just a directory name *)
      let normalized_filename =
        if
          String.length filename > 0
          && filename.[String.length filename - 1] = '/'
        then
          (* Remove trailing slash if present *)
          String.sub filename 0 (String.length filename - 1)
        else filename
      in
      (* A file has an extension (contains a dot that is not at the start) *)
      let has_extension filename =
        match String.rindex_opt filename '.' with
        | Some pos when pos > 0 -> true
        | _ -> false
      in
      has_extension normalized_filename )
    files

(* Convert (uri * uri) list to Api.Openapi.sourceArtifact list *)
let convert_to_source_artifacts (files : (string * string) list) :
    Api.Openapi.sourceArtifact list =
  List.map
    (fun (filename, content) ->
      Api.Openapi.create_sourceArtifact ~filename ~content () )
    files

(* use openapi to send the problem *)
let create_problem_from_zip contest_id problem_name files =
  let input_spec = "Input specification placeholder" in
  let output_spec = "Output specification placeholder" in
  let description = "Problem created from ZIP import" in
  let time_limit_ms = 1000 in
  let memory_limit_mb = 256 in
  let languages = get_supported_languages files in
  let source_artifacts = convert_to_source_artifacts files in
  let body =
    Api.Openapi.ProblemCreateRequest.create ~code:problem_name
      ~title:problem_name ~description ~input_spec ~output_spec
      ~time_limit_ms ~memory_limit_mb ~languages ~source_artifacts ()
    |> Api.Openapi.ProblemCreateRequest.to_json
  in
  Api.Helpers.post_problem contest_id body
  >>= fun (_resp, status) ->
  if status <> 200 && status <> 201 then (
    Console.console##log
      (Js.string
         (Printf.sprintf "Failed to create problem %s: %d" problem_name
            status ) ) ;
    Lwt.return_unit )
  else (
    Console.console##log
      (Js.string
         (Printf.sprintf "Successfully created problem %s" problem_name) ) ;
    RerenderFlag.set_rerender () ;
    Helpers.trigger_render () ;
    Lwt.return_unit )

let process_zip_file contest_id file_input =
  Lwt.async (fun () ->
      try
        read_file_as_arraybuffer file_input
        >>= fun buffer ->
        extract_zip_contents buffer
        >>= fun files ->
        Console.console##log
          (Js.string
             (Printf.sprintf "Extracted %d files from ZIP"
                (List.length files) ) ) ;
        Console.console##log
          (Js.string
             (Printf.sprintf "Files: %s"
                (String.concat ", "
                   (List.map (fun (name, _) -> name) files) ) ) ) ;
        (* exclude nested hidden folders *)
        let files =
          List.filter
            (fun (name, _) -> not (is_hidden_folder_or_file name))
            files
        in
        (* folder names are problem names *)
        let problem_names = problem_names_from_paths (List.map fst files) in
        Console.console##log
          (Js.string
             (Printf.sprintf "Found %d problems in ZIP"
                (List.length problem_names) ) ) ;
        let files = remove_folders_from_files files in
        let test_case_files = get_test_case_files files in
        (* Here you would process the test_case_files and create problems *)
        Console.console##log
          (Js.string
             (Printf.sprintf "Found %d test case files in ZIP"
                (List.length test_case_files) ) ) ;
        (* For each problem, call the API to create the problem and upload
           artifacts and test cases *)
        Lwt_list.iter_p
          (fun problem_name ->
            create_problem_from_zip contest_id problem_name files )
          problem_names
      with exn ->
        Console.console##log
          (Js.string
             ("Error processing ZIP import: " ^ Printexc.to_string exn) ) ;
        Lwt.return_unit )

(* --- UI Card Component --- *)

let render_import_card contest_id () =
  Settings_helpers.section_card
    (I18n.t "settings_import_zip_card_title")
    [ label
        ~a:[a_class ["form-label"]]
        [txt (I18n.t "settings_import_zip_description")]
    ; div
        ~a:[a_class ["d-flex"; "gap-2"; "mb-3"]]
        [ div
            ~a:[a_class ["position-relative"; "flex-grow-1"]]
            [ input
                ~a:
                  [ a_id "zip-file-input"
                  ; a_input_type `File
                  ; a_accept [".zip"]
                  ; a_class ["form-control"]
                  ; a_onchange (fun _ -> false) ]
                () ]
        ; div
            ~a:[a_class ["d-flex"; "justify-content-center"]]
            [ button
                ~a:
                  [ a_class ["btn"; "btn-primary"]
                  ; a_onclick (fun _ ->
                        let input =
                          Dom_html.CoerceTo.input
                            (Dom_html.getElementById "zip-file-input")
                        in
                        match Js.Opt.to_option input with
                        | None -> false
                        | Some element -> (
                            let files = element##.files in
                            match Js.Opt.to_option files with
                            | None -> false
                            | Some file_list ->
                                ( if file_list##.length > 0 then
                                    let file_input = file_list##item 0 in
                                    match Js.Opt.to_option file_input with
                                    | None ->
                                        Console.console##log
                                          (Js.string "No file selected")
                                    | Some file ->
                                        process_zip_file contest_id file ) ;
                                false ) ) ]
                [txt (I18n.t "settings_import_zip_button")] ] ] ]
