open Js_of_ocaml

type language = EN | FR | ES | PT | AR

let language_of_code = function
  | "en" -> EN
  | "fr" -> FR
  | "es" -> ES
  | "pt" -> PT
  | "ar" -> AR
  | _ -> EN

let language_to_code = function
  | EN -> "en"
  | FR -> "fr"
  | ES -> "es"
  | PT -> "pt"
  | AR -> "ar"

let apply_direction lang =
  let dir = match lang with AR -> "rtl" | _ -> "ltr" in
  let body = Js.Unsafe.get Dom_html.document "body" in
  ignore
    (Js.Unsafe.fun_call
       (Js.Unsafe.get body "setAttribute")
       [| Js.Unsafe.inject (Js.string "dir")
        ; Js.Unsafe.inject (Js.string dir) |] )

let current_language () =
  Helpers.get_local_variable "yoda-language"
  |> Option.map Js.to_string
  |> function
  | Some code -> language_of_code code
  | None -> EN (* defaults to English *)

let set_language lang =
  let code = language_to_code lang in
  Helpers.set_local_variable "yoda-language" code ;
  apply_direction lang

let languages =
  [ (EN, "English")
  ; (FR, "Français")
  ; (ES, "Español")
  ; (PT, "Português")
  ; (AR, "العربية") ]

let get_translations () =
  match current_language () with
  | EN -> Translations.en
  | FR -> Translations.fr
  | ES -> Translations.es
  | PT -> Translations.pt
  | AR -> Translations.ar

let t key =
  let tr = get_translations () in
  try Hashtbl.find (Translations.map tr) key
  with Not_found -> failwith ("Translation key not found: " ^ key)

let interpolate template values =
  let buf = Buffer.create (String.length template) in
  let i = ref 0 in
  let values = ref values in
  while !i < String.length template do
    if
      !i + 1 < String.length template
      && template.[!i] = '%'
      && template.[!i + 1] = 's'
    then begin
      ( match !values with
      | v :: vs ->
          Buffer.add_string buf v ;
          values := vs
      | [] -> Buffer.add_string buf "%s" ) ;
      i := !i + 2
    end
    else begin
      Buffer.add_char buf template.[!i] ;
      incr i
    end
  done ;
  Buffer.contents buf

let init () =
  match current_language () with
  | EN -> set_language EN
  | FR -> set_language FR
  | ES -> set_language ES
  | PT -> set_language PT
  | AR -> set_language AR
