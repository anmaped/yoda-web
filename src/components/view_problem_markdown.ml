open Js_of_ocaml

(** Remove YAML front matter. *)
let strip_yaml_front_matter text =
  let lines = String.split_on_char '\n' text in
  match lines with
  | "---" :: rest ->
      let rec consume = function
        | "---" :: tail -> tail
        | _ :: tail -> consume tail
        | [] -> []
      in
      String.concat "\n" (consume rest)
  | _ -> text

(** Remove myst directives from the markdown text. *)
let strip_myst_directives text =
  let lines = String.split_on_char '\n' text in
  let rec loop acc = function
    | [] -> String.concat "\n" (List.rev acc)
    | line :: rest ->
        let trimmed = String.trim line in
        if String.starts_with ~prefix:"```{" trimmed then
          let directive_name =
            let inner =
              String.trim (String.sub trimmed 4 (String.length trimmed - 4))
            in
            if inner = "" || inner.[0] <> '{' then ""
            else
              let close_idx =
                try String.index_from inner 1 '}' with Not_found -> -1
              in
              if close_idx < 0 then "" else String.sub inner 1 (close_idx - 1)
          in
          let rec collect_inner acc_inner = function
            | [] -> (List.rev acc_inner, [])
            | current :: tail ->
                let current_trimmed = String.trim current in
                if current_trimmed = "```" then (List.rev acc_inner, tail)
                else if current_trimmed <> "" && current_trimmed.[0] = ':'
                then collect_inner acc_inner tail
                else collect_inner (current :: acc_inner) tail
          in
          let inner_lines, remaining = collect_inner [] rest in
          if directive_name = "eval-rst" || directive_name = "graphviz" then
            loop acc remaining
          else loop (List.rev inner_lines @ acc) remaining
        else if String.starts_with ~prefix:"```" trimmed then
          loop (line :: acc) rest
        else loop (line :: acc) rest
  in
  loop [] lines

(** Preprocess the markdown text by removing YAML front matter and myst directives. *)
let preprocess_markdown text =
  text |> strip_yaml_front_matter |> strip_myst_directives

let codemirror_mode_of_markdown_lang lang =
  match String.lowercase_ascii (String.trim lang) with
  | "" | "text" | "plain" | "plaintext" -> "text/plain"
  | "ocaml" | "ml" | "reason" -> "text/x-ocaml"
  | "js" | "jsx" | "javascript" | "node" -> "text/javascript"
  | "ts" | "tsx" | "typescript" -> "text/typescript"
  | "json" -> "application/json"
  | "html" | "xhtml" -> "text/html"
  | "css" -> "text/css"
  | "xml" -> "application/xml"
  | "c" -> "text/x-csrc"
  | "cpp" | "c++" | "cc" | "cxx" -> "text/x-c++src"
  | "java" -> "text/x-java"
  | "python" | "py" -> "text/x-python"
  | "ruby" | "rb" -> "text/x-ruby"
  | "shell" | "sh" | "bash" | "zsh" -> "text/x-sh"
  | "sql" -> "text/x-sql"
  | "markdown" | "md" -> "text/x-markdown"
  | "yaml" | "yml" -> "text/x-yaml"
  | "diff" | "patch" -> "text/x-diff"
  | _ -> "text/plain"

let highlight_with_codemirror ~code ~lang =
  match
    Js.Optdef.to_option (Js.Unsafe.get Js.Unsafe.global "CodeMirror")
  with
  | None -> failwith "CodeMirror not found"
  | Some code_mirror ->
      let mode =
        if String.trim lang = "" then "text/plain"
        else codemirror_mode_of_markdown_lang (String.trim lang)
      in
      let sink = Dom_html.createDiv Dom_html.document in
      sink##.className :=
        Js.string (Editor.current_codemirror_theme_class ()) ;
      ignore
        (Js.Unsafe.meth_call code_mirror "runMode"
           [| Js.Unsafe.inject (Js.string code)
            ; Js.Unsafe.inject (Js.string mode)
            ; Js.Unsafe.inject sink |] ) ;
      Js.to_string sink##.outerHTML

let render_markdown text =
  let cleaned = preprocess_markdown text in
  match
    Js.Optdef.to_option (Js.Unsafe.get Js.Unsafe.global "markdownit")
  with
  | None -> cleaned
  | Some markdownit_factory ->
      let highlight_callback =
        Js.wrap_callback (fun code lang ->
            let code = Js.to_string code in
            let lang = Js.to_string lang in
            Js.string
              ( try highlight_with_codemirror ~code ~lang
                with _ -> failwith "Error in highlighting" ) )
      in
      let options =
        Js.Unsafe.obj
          [| ("html", Js.Unsafe.inject (Js.bool true))
           ; ("linkify", Js.Unsafe.inject (Js.bool true))
           ; ("typographer", Js.Unsafe.inject (Js.bool true))
           ; ("highlight", Js.Unsafe.inject highlight_callback) |]
      in
      let markdownit =
        Js.Unsafe.fun_call markdownit_factory [|Js.Unsafe.inject options|]
      in
      let rendered =
        Js.Unsafe.meth_call markdownit "render"
          [|Js.Unsafe.inject (Js.string cleaned)|]
      in
      Js.to_string rendered
