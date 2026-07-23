open Js_of_ocaml
open Js_of_ocaml_tyxml
open Tyxml_js.Html

type language = EN | FR | ES | PT | AR

let current_language () =
  Helpers.get_local_variable "yoda-language"
  |> Option.map Js.to_string
  |> function
  | Some "en" -> EN
  | Some "fr" -> FR
  | Some "es" -> ES
  | Some "pt" -> PT
  | Some "ar" -> AR
  | _ -> EN (* defaults to English *)

let set_language lang =
  let code =
    match lang with
    | EN -> "en"
    | FR -> "fr"
    | ES -> "es"
    | PT -> "pt"
    | AR -> "ar"
  in
  Helpers.set_local_variable "yoda-language" code

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

let init () =
  match current_language () with
  | EN -> set_language EN
  | FR -> set_language FR
  | ES -> set_language ES
  | PT -> set_language PT
  | AR -> set_language AR
