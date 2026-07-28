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

let dashboard_icon =
  let open Tyxml_js.Svg in
  Tyxml_js.Html.svg
    ~a:
      [ a_width (24., Some `Px)
      ; a_height (24., Some `Px)
      ; a_fill (`Color ("currentColor", None))
      ; a_class ["bi"; "bi-speedometer2"]
      ; a_viewBox (-0., -0., 16., 16.) ]
    [ path
        ~a:
          [ a_d
              "M13 6.5a.5.5 0 0 0-.5-.5h-5a.5.5 0 0 0 0 1h5a.5.5 0 0 0 \
               .5-.5m0 3a.5.5 0 0 0-.5-.5h-5a.5.5 0 0 0 0 1h5a.5.5 0 0 0 \
               .5-.5m-.5 2.5a.5.5 0 0 1 0 1h-5a.5.5 0 0 1 0-1z" ]
        []
    ; path
        ~a:
          [ a_fill_rule `Evenodd
          ; a_d
              "M14 0a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2H2a2 2 0 0 1-2-2V2a2 2 0 \
               0 1 2-2zM2 1a1 1 0 0 0-1 1v1h14V2a1 1 0 0 0-1-1zM1 4v10a1 1 \
               0 0 0 1 1h2V4zm4 0v11h9a1 1 0 0 0 1-1V4z" ]
        [] ]

let journal_code_icon =
  let open Tyxml_js.Svg in
  Tyxml_js.Html.svg
    ~a:
      [ a_width (24., Some `Px)
      ; a_height (24., Some `Px)
      ; a_fill (`Color ("currentColor", None))
      ; a_class ["bi"; "bi-speedometer2"]
      ; a_viewBox (-0., -0., 16., 16.) ]
    [ path
        ~a:
          [ a_fill_rule `Evenodd
          ; a_d
              "M8.646 5.646a.5.5 0 0 1 .708 0l2 2a.5.5 0 0 1 0 .708l-2 \
               2a.5.5 0 0 1-.708-.708L10.293 8 8.646 6.354a.5.5 0 0 1 \
               0-.708m-1.292 0a.5.5 0 0 0-.708 0l-2 2a.5.5 0 0 0 0 .708l2 \
               2a.5.5 0 0 0 .708-.708L5.707 8l1.647-1.646a.5.5 0 0 0 0-.708"
          ]
        []
    ; path
        ~a:
          [ a_d
              "M3 0h10a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2H3a2 2 0 0 \
               1-2-2v-1h1v1a1 1 0 0 0 1 1h10a1 1 0 0 0 1-1V2a1 1 0 0 \
               0-1-1H3a1 1 0 0 0-1 1v1H1V2a2 2 0 0 1 2-2" ]
        []
    ; path
        ~a:
          [ a_d
              "M1 5v-.5a.5.5 0 0 1 1 0V5h.5a.5.5 0 0 1 0 1h-2a.5.5 0 0 1 \
               0-1zm0 3v-.5a.5.5 0 0 1 1 0V8h.5a.5.5 0 0 1 0 1h-2a.5.5 0 0 \
               1 0-1zm0 3v-.5a.5.5 0 0 1 1 0v.5h.5a.5.5 0 0 1 0 1h-2a.5.5 0 \
               0 1 0-1z" ]
        [] ]

let table_icon =
  let open Tyxml_js.Svg in
  Tyxml_js.Html.svg
    ~a:
      [ a_width (24., Some `Px)
      ; a_height (24., Some `Px)
      ; a_fill (`Color ("currentColor", None))
      ; a_class ["bi"; "bi-speedometer2"]
      ; a_viewBox (-0., -0., 16., 16.) ]
    [ path
        ~a:
          [ a_d
              "M0 2a2 2 0 0 1 2-2h12a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2H2a2 2 0 \
               0 1-2-2zm15 2h-4v3h4zm0 4h-4v3h4zm0 4h-4v3h3a1 1 0 0 0 \
               1-1zm-5 3v-3H6v3zm-5 0v-3H1v2a1 1 0 0 0 1 \
               1zm-4-4h4V8H1zm0-4h4V4H1zm5-3v3h4V4zm4 4H6v3h4z" ]
        [] ]

let arrow_left_right =
  let open Tyxml_js.Svg in
  Tyxml_js.Html.svg
    ~a:
      [ a_width (24., Some `Px)
      ; a_height (24., Some `Px)
      ; a_fill (`Color ("currentColor", None))
      ; a_class ["bi"; "bi-arrow-left-right"]
      ; a_viewBox (0., 0., 16., 16.) ]
    [ path
        ~a:
          [ a_fill_rule `Evenodd
          ; a_d
              "M1 11.5a.5.5 0 0 0 .5.5h11.793l-3.147 3.146a.5.5 0 0 0 \
               .708.708l4-4a.5.5 0 0 0 0-.708l-4-4a.5.5 0 0 \
               0-.708.708L13.293 11H1.5a.5.5 0 0 0-.5.5m14-7a.5.5 0 0 \
               1-.5.5H2.707l3.147 3.146a.5.5 0 1 1-.708.708l-4-4a.5.5 0 0 1 \
               0-.708l4-4a.5.5 0 1 1 .708.708L2.707 4H14.5a.5.5 0 0 1 .5.5"
          ]
        [] ]

let gear_icon =
  let open Tyxml_js.Svg in
  Tyxml_js.Html.svg
    ~a:
      [ a_class ["bi"]
      ; a_width (24., Some `Px)
      ; a_height (24., Some `Px)
      ; Unsafe.string_attrib "viewBox" "0 0 16 16" ]
    [ path
        ~a:
          [ Unsafe.string_attrib "fill" "currentColor"
          ; Unsafe.string_attrib "d"
              "M11 5a3 3 0 1 1-6 0 3 3 0 0 1 6 0m-9 8c0 1 1 1 1 1h5.256A4.5 \
               4.5 0 0 1 8 12.5a4.5 4.5 0 0 1 1.544-3.393Q8.844 9.002 8 \
               9c-5 0-6 3-6 4m9.886-3.54c.18-.613 1.048-.613 1.229 \
               0l.043.148a.64.64 0 0 0 .921.382l.136-.074c.561-.306 \
               1.175.308.87.869l-.075.136a.64.64 0 0 0 \
               .382.92l.149.045c.612.18.612 1.048 0 1.229l-.15.043a.64.64 0 \
               0 0-.38.921l.074.136c.305.561-.309 \
               1.175-.87.87l-.136-.075a.64.64 0 0 \
               0-.92.382l-.045.149c-.18.612-1.048.612-1.229 \
               0l-.043-.15a.64.64 0 0 \
               0-.921-.38l-.136.074c-.561.305-1.175-.309-.87-.87l.075-.136a.64.64 \
               0 0 0-.382-.92l-.148-.045c-.613-.18-.613-1.048 \
               0-1.229l.148-.043a.64.64 0 0 0 \
               .382-.921l-.074-.136c-.306-.561.308-1.175.869-.87l.136.075a.64.64 \
               0 0 0 .92-.382zM14 12.5a1.5 1.5 0 1 0-3 0 1.5 1.5 0 0 0 3 0"
          ]
        [] ]

let box_arrow_right_icon =
  let open Tyxml_js.Svg in
  Tyxml_js.Html.svg
    ~a:
      [ a_width (24., Some `Px)
      ; a_height (24., Some `Px)
      ; Unsafe.string_attrib "viewBox" "0 0 16 16" ]
    [ path
        ~a:
          [ Unsafe.string_attrib "fill" "currentColor"
          ; Unsafe.string_attrib "d"
              "M10 12.5a.5.5 0 0 1-.5.5h-7a.5.5 0 0 1-.5-.5v-9a.5.5 0 0 1 \
               .5-.5h7a.5.5 0 0 1 .5.5v2a.5.5 0 0 0 1 0v-2A1.5 1.5 0 0 0 \
               9.5 2h-7A1.5 1.5 0 0 0 1 3.5v9A1.5 1.5 0 0 0 2.5 14h7a1.5 \
               1.5 0 0 0 1.5-1.5v-2a.5.5 0 0 0-1 0v2z" ]
        []
    ; path
        ~a:
          [ Unsafe.string_attrib "fill" "currentColor"
          ; Unsafe.string_attrib "d"
              "M15.854 8.354a.5.5 0 0 0 0-.708l-3-3a.5.5 0 0 \
               0-.708.708L14.293 7.5H5.5a.5.5 0 0 0 0 1h8.793l-2.147 \
               2.146a.5.5 0 0 0 .708.708l3-3z" ]
        [] ]

let sidebar ?(only_icons = false) () =
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
      [ a_class ["d-flex"; "flex-column"; "flex-shrink-0"; "bg-body-tertiary"]
      ; a_style
          ( if only_icons then "width: 4.5rem; height: inherit;"
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
            [ img ~src:"yoda2.png" ~alt:"Yoda Logo"
                ~a:[a_class ["yoda-logo"; "mx-auto"]; a_width (if only_icons then 0 else 96)]
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
        [ img ~src:"yoda2.png" ~alt:"Yoda Logo"
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
              ; "flex-column"
              ; "mb-auto"
              ; "text-center" ] ]
        [ (* Dashboard *)
          li
            ~a:[a_class ["nav-item"]]
            [ nav_link "#dashboard"
                (I18n.t "sidebar_dashboard")
                dashboard_icon
                (if only_icons then "D" else I18n.t "sidebar_dashboard") ]
        ; (* Submit *)
          li
            ~a:[a_class ["nav-item"]]
            [ nav_link "#codeboard"
                (I18n.t "sidebar_codeboard")
                journal_code_icon
                (if only_icons then "C" else I18n.t "sidebar_codeboard") ]
        ; (* Submissions *)
          li
            ~a:[a_class ["nav-item"]]
            [ nav_link "#submissions"
                (I18n.t "sidebar_submissions")
                table_icon
                (if only_icons then "S" else I18n.t "sidebar_submissions") ]
        ; (* Switch Contest *)
          li
            ~a:[a_class ["nav-item"]]
            [ nav_link "#contests"
                (I18n.t "sidebar_switch_contest")
                arrow_left_right
                (if only_icons then "" else I18n.t "sidebar_switch_contest")
            ]
        ; (* Settings *)
          li
            ~a:[a_class ["nav-item"]]
            [ nav_link "#settings"
                (I18n.t "sidebar_settings")
                gear_icon
                (if only_icons then "" else I18n.t "sidebar_settings") ]
        ; (* Sign out *)
          li
            ~a:[a_class ["nav-item"]]
            [ nav_link "#logout"
                (I18n.t "sidebar_sign_out")
                box_arrow_right_icon
                (if only_icons then "" else I18n.t "sidebar_sign_out") ] ] ]

let sidebar () =
  if Helpers.is_mobile () then div []
  else if Helpers.is_wide_desktop () then sidebar ()
  else sidebar ~only_icons:true ()
