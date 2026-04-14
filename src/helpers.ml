open Js_of_ocaml
open Js_of_ocaml_tyxml
open Tyxml_js.Html

let remove_first_element_from_app element =
  let doc = Dom_html.document in
  match Js.Opt.to_option (doc##querySelector (Js.string element)) with
  | Some el ->
      ignore (Js.Unsafe.meth_call el "remove" [||]) ;
      Console.console##log (Js.string ("Element removed: " ^ element))
  | None ->
      Console.console##log (Js.string ("Element not found: " ^ element))

let add_element_to_app element =
  let app_div = Dom_html.getElementById "app" in
  let dom_element = Tyxml_js.To_dom.of_div element in
  Dom.appendChild app_div dom_element ;
  Console.console##log
    (Js.string ("Element added: " ^ Js.to_string dom_element##.id))

let make_modal_view name title content action () =
  div
    ~a:[a_id name]
    [ (* backdrop *)
      div ~a:[a_class ["modal-backdrop"; "fade"; "show"]] []
    ; (* modal *)
      div
        ~a:[a_class ["modal"; "fade"; "show"]; a_style "display:block;"]
        [ div
            ~a:[a_class ["modal-dialog"]]
            [ div
                ~a:[a_class ["modal-content"]]
                [ div
                    ~a:[a_class ["modal-header"]]
                    [ h5 ~a:[a_class ["modal-title"]] [txt title]
                    ; button
                        ~a:
                          [ a_class ["btn-close"]
                          ; a_onclick (fun _ ->
                                remove_first_element_from_app ("#" ^ name) ;
                                false ) ]
                        [] ]
                ; div ~a:[a_class ["modal-body"]] content
                ; div
                    ~a:[a_class ["modal-footer"]]
                    [ button
                        ~a:
                          [ a_class ["btn"; "btn-secondary"]
                          ; a_onclick (fun _ ->
                                remove_first_element_from_app ("#" ^ name) ;
                                false ) ]
                        [txt "Cancel"]
                    ; button
                        ~a:
                          [ a_class ["btn"; "btn-primary"]
                          ; a_onclick (fun _ ->
                                remove_first_element_from_app ("#" ^ name) ;
                                action () ) ]
                        [txt "Confirm"] ] ] ] ] ]

let make_spinner id () =
  div
    ~a:
      [ a_id ("spinner-" ^ id)
      ; a_class ["spinner-border"; "spinner-border-sm"; "text-primary"]
      ; a_role ["status"] ]
    [span ~a:[a_class ["visually-hidden"]] [txt " "]]

let hide id () =
  let el = Dom_html.getElementById id in
  el##.style##.display := Js.string "none" ;
  Console.console##log (Js.string ("Element hidden: " ^ id))

let make_spinner_modal () =
  div
    [ (* backdrop *)
      div ~a:[a_class ["modal-backdrop"; "fade"; "show"]] []
    ; (* fullscreen modal *)
      div
        ~a:[a_class ["modal"; "fade"; "show"]; a_style "display:block;"]
        [ div
            ~a:[a_class ["modal-dialog"; "modal-fullscreen"]]
            [ div
                ~a:[a_class ["modal-content"]]
                [ (* header *)
                  div
                    ~a:[a_class ["modal-header"]]
                    [ h5 ~a:[a_class ["modal-title"]] [txt "Processing..."]
                    ; button
                        ~a:[a_class ["btn-close"]; a_onclick (fun _ -> false)]
                        [] ]
                ; (* body *)
                  div
                    ~a:[a_class ["modal-body"]]
                    [ div
                        [ txt "Ready to start operation."
                        ; br ()
                        ; button
                            ~a:
                              [ a_class ["btn"; "btn-primary"; "mt-3"]
                              ; a_onclick (fun _ -> false) ]
                            [txt "Start"] ] ] ] ] ] ]

let is_mobile () =
  let width = Dom_html.window##.innerWidth in
  width < 560

let is_wide_desktop () =
  let width = Dom_html.window##.innerWidth in
  width >= 1200

(* Local Storage and Session Storage Helpers *)
let set_session_variable key value =
  Js.Optdef.iter Dom_html.window##.sessionStorage (fun storage ->
      storage##setItem (Js.string key) (Js.string value) )

let get_session_variable key =
  match Js.Optdef.to_option Dom_html.window##.sessionStorage with
  | Some storage -> Js.Opt.to_option (storage##getItem (Js.string key))
  | None -> None

let set_local_variable key value =
  Js.Optdef.iter Dom_html.window##.localStorage (fun storage ->
      storage##setItem (Js.string key) (Js.string value) )

let get_local_variable key =
  match Js.Optdef.to_option Dom_html.window##.localStorage with
  | Some storage -> Js.Opt.to_option (storage##getItem (Js.string key))
  | None -> None

let username () =
  match get_session_variable "username" with
  | Some t -> Js.to_string t
  | None -> "Guest"

let is_valid_json s =
  try
    ignore (Yojson.Basic.from_string s) ;
    true
  with _ -> false

let get_element_by_id id =
  match
    Js.Opt.to_option (Dom_html.document##getElementById (Js.string id))
  with
  | None -> failwith ("Missing element #" ^ id)
  | Some el -> el

let append_child_by_id parent_id child =
  let parent = get_element_by_id parent_id in
  (* Convert Tyxml element to DOM node *)
  let child_node = Tyxml_js.To_dom.of_element child in
  Dom.appendChild parent child_node ;
  (* Safely coerce to Dom_html.element to access .##id *)
  let child_el_opt =
    Dom_html.CoerceTo.element child_node |> Js.Opt.to_option
  in
  let child_id =
    match child_el_opt with
    | Some el -> Js.to_string el##.id
    | None -> "(unknown)"
  in
  Console.console##log
    (Js.string ("Child \"" ^ child_id ^ "\" appended to #" ^ parent_id))

let remove_element_by_id id =
  let el = get_element_by_id id in
  ignore (Js.Unsafe.meth_call el "remove" [||]) ;
  Console.console##log (Js.string ("Element removed: #" ^ id))

let get_problem () =
  (* get problem from get variables *)
  let url = Dom_html.window##.location in
  let search = url##.search in
  let params = Js.to_string search |> Astring.String.with_range ~first:1 in
  let param_list = Astring.String.cuts ~sep:"&" params in
  let param_map =
    List.fold_left
      (fun acc param ->
        match Astring.String.cut ~sep:"=" param with
        | Some (key, value) -> (key, value) :: acc
        | None -> acc )
      [] param_list
  in
  match List.assoc_opt "problem" param_map with
  | Some problem -> problem
  | None -> (
    (* Fallback to session variable if not in URL *)
    match get_session_variable "problem" with
    | Some p -> Js.to_string p
    | None -> "unknown_problem" )
