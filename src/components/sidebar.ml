open Js_of_ocaml
open Js_of_ocaml_tyxml
open Tyxml_js.Html

let nav_to path =
  Dom_html.window##.history##pushState
    Js.null (Js.string "")
    (Js.Opt.return (Js.string path)) ;
  Dom_html.window##.location##reload

let initials () =
  let get_session_username () =
    Js.Optdef.case
      Dom_html.window##.sessionStorage
      (fun () -> "")
      (fun storage ->
        Js.Opt.case
          (storage##getItem (Js.string "username"))
          (fun () -> "")
          Js.to_string )
  in
  get_session_username () |> String.split_on_char ' '
  |> List.filter (fun s -> String.length s > 0)
  |> List.map (fun s -> String.uppercase_ascii (String.sub s 0 1))
  |> fun xs -> match xs with a :: b :: _ -> a ^ b | [a] -> a | [] -> "?"

let sidebar ?(only_icons = false) ?(horizontal = false) () =
  let current_hash = Js.to_string Dom_html.window##.location##.hash in
  let nav_link href label icon msg =
    let active_class =
      if current_hash = "" && href = "#dashboard" then "active"
      else if current_hash = href then "active"
      else ""
    in
    a
      ~a:
        [ a_href href
        ; a_class
            [ "nav-link"
            ; active_class
            ; "d-flex"
            ; "align-items-center"
            ; "py-3"
            ; "border-bottom"
            ; "rounded-0" ]
        ; Unsafe.string_attrib "data-bs-toggle" "tooltip"
        ; Unsafe.string_attrib "data-bs-placement" "right"
        ; a_aria "label" [label]
        ; a_title label
        ; Unsafe.string_attrib "data-bs-original-title" label ]
      [icon; span ~a:[a_class ["ms-2"]] [txt msg]]
  in
  div
    ~a:
      [ a_class
          [ "d-flex"
          ; (if horizontal then "flex-row" else "flex-column")
          ; "flex-shrink-0"
          ; "bg-body-tertiary" ]
      ; a_style
          ( if only_icons then
              if horizontal then "" else "width: 4.5rem; height: inherit;"
            else "width: 11rem; height: inherit;" ) ]
    [ (* User initials *)
      div
        ~a:[a_class ["border-bottom"; "py-3"; "text-center"]]
        [ span
            ~a:
              [ a_class
                  [ "rounded-circle"
                  ; "bg-secondary"
                  ; "text-white"
                  ; "d-inline-flex"
                  ; "align-items-center"
                  ; "justify-content-center" ]
              ; a_style
                  "width:64px; height:64px; font-size:0.9rem; \
                   font-weight:600;" ]
            [txt (initials ())]
        ; a
            ~a:
              [ a_href "#about"
              ; a_class ["link-body-emphasis"; "text-decoration-none"]
              ; Unsafe.string_attrib "data-bs-toggle" "tooltip"
              ; Unsafe.string_attrib "data-bs-placement" "right"
              ; Unsafe.string_attrib "data-bs-original-title" "About" ]
            [ img ~src:Blobs.yoda_logo_url ~alt:"Yoda Logo"
                ~a:
                  [ a_class ["yoda-logo"; "mx-auto"]
                  ; a_width (if only_icons then 0 else 96) ]
                ()
            ; span ~a:[a_class ["visually-hidden"]] [txt "About"] ] ]
    ; (* Logo *)
      (*a
        ~a:
          [ a_href "#about"
          ; a_class
              ["d-block"; "p-3"; "link-body-emphasis"; "text-decoration-none"]
          ; Unsafe.string_attrib "data-bs-toggle" "tooltip"
          ; Unsafe.string_attrib "data-bs-placement" "right"
          ; Unsafe.string_attrib "data-bs-original-title" "About" ]
        [ img ~src:yoda_logo_url ~alt:"Yoda Logo"
            ~a:[a_class ["yoda-logo"; "d-block"; "mx-auto"]; a_width 50]
            ()
        ; span ~a:[a_class ["visually-hidden"]] [txt "About"] ]
    ;*)
      ul
        ~a:
          [ a_class
              [ "nav"
              ; "nav-pills"
              ; "nav-flush"
              ; (if horizontal then "flex-row" else "flex-column")
              ; "mb-auto"
              ; "text-center" ] ]
        [ (* Dashboard *)
          li
            ~a:[a_class ["nav-item"]]
            [ nav_link "#dashboard"
                (I18n.t "sidebar_dashboard")
                (Icons.dashboard_icon ())
                (if only_icons then "D" else I18n.t "sidebar_dashboard") ]
        ; (* Submit *)
          li
            ~a:[a_class ["nav-item"]]
            [ nav_link "#codeboard"
                (I18n.t "sidebar_codeboard")
                (Icons.journal_code_icon ())
                (if only_icons then "C" else I18n.t "sidebar_codeboard") ]
        ; (* Submissions *)
          li
            ~a:[a_class ["nav-item"]]
            [ nav_link "#submissions"
                (I18n.t "sidebar_submissions")
                (Icons.table_icon ())
                (if only_icons then "S" else I18n.t "sidebar_submissions") ]
        ; (* Switch Contest *)
          li
            ~a:[a_class ["nav-item"]]
            [ nav_link "#contests"
                (I18n.t "sidebar_switch_contest")
                (Icons.arrow_left_right ())
                (if only_icons then "" else I18n.t "sidebar_switch_contest")
            ]
        ; (* Settings *)
          li
            ~a:[a_class ["nav-item"]]
            [ nav_link "#settings"
                (I18n.t "sidebar_settings")
                (Icons.gear_icon ())
                (if only_icons then "" else I18n.t "sidebar_settings") ]
        ; (* Sign out *)
          li
            ~a:[a_class ["nav-item"]]
            [ nav_link "#logout"
                (I18n.t "sidebar_sign_out")
                (Icons.box_arrow_right_icon ())
                (if only_icons then "" else I18n.t "sidebar_sign_out") ] ] ]

let sidebar ?(mobile = false) ?(wide = true) () =
  if mobile then sidebar ~only_icons:true ~horizontal:true ()
  else if wide then sidebar ()
  else sidebar ~only_icons:true ()
