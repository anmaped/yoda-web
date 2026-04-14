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
      [ a_width (16., Some `Px)
      ; a_height (16., Some `Px)
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
      [ a_width (16., Some `Px)
      ; a_height (16., Some `Px)
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
      [ a_width (16., Some `Px)
      ; a_height (16., Some `Px)
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
      [ a_width (16., Some `Px)
      ; a_height (16., Some `Px)
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

let icon_only_sidebar () =
  div
    ~a:
      [ a_class ["d-flex"; "flex-column"; "flex-shrink-0"; "bg-body-tertiary"]
      ; a_style "width: 4.5rem; height: inherit;" ]
    [ a
        ~a:
          [ a_href "#about"
          ; a_class
              ["d-block"; "p-3"; "link-body-emphasis"; "text-decoration-none"]
          ; Unsafe.string_attrib "data-bs-toggle" "tooltip"
          ; Unsafe.string_attrib "data-bs-placement" "right"
          ; Unsafe.string_attrib "data-bs-original-title" "Icon-only" ]
        [ img ~src:"yoda2.png" ~alt:"Yoda Logo"
            ~a:[a_class ["yoda-logo"; "d-block"; "mx-auto"]; a_width 50]
            ()
        ; span ~a:[a_class ["visually-hidden"]] [txt "Icon-only"] ]
    ; ul
        ~a:
          [ a_class
              [ "nav"
              ; "nav-pills"
              ; "nav-flush"
              ; "flex-column"
              ; "mb-auto"
              ; "text-center" ] ]
        [ li
            ~a:[a_class ["nav-item"]]
            [ a
                ~a:
                  [ a_href "#dashboard"
                  ; a_class
                      [ "nav-link"
                      ; (let hash =
                           Js.to_string Dom_html.window##.location##.hash
                         in
                         if hash = "" || hash = "#dashboard" then "active"
                         else "" )
                      ; "py-3"
                      ; "border-bottom"
                      ; "rounded-0" ]
                  ; Unsafe.string_attrib "aria-current" "page"
                  ; Unsafe.string_attrib "data-bs-toggle" "tooltip"
                  ; Unsafe.string_attrib "data-bs-placement" "right"
                  ; a_aria "label" ["Contests"]
                  ; a_title "This is the dashboard"
                  ; Unsafe.string_attrib "data-bs-original-title" "Contests"
                  ]
                [dashboard_icon] ]
        ; li
            [ a
                ~a:
                  [ a_href "#codeboard"
                  ; a_class
                      [ "nav-link"
                      ; (let hash =
                           Js.to_string Dom_html.window##.location##.hash
                         in
                         if hash = "#codeboard" then "active" else "" )
                      ; "py-3"
                      ; "border-bottom"
                      ; "rounded-0" ]
                  ; Unsafe.string_attrib "data-bs-toggle" "tooltip"
                  ; Unsafe.string_attrib "data-bs-placement" "right"
                  ; a_aria "label" ["Submit"]
                  ; a_title "This is the submission board"
                  ; Unsafe.string_attrib "data-bs-original-title" "Submit"
                  ; Unsafe.string_attrib "aria-describedby" "tooltip256851"
                  ]
                [journal_code_icon] ]
        ; li
            [ a
                ~a:
                  [ a_href "#submissions"
                  ; a_class
                      [ "nav-link"
                      ; (let hash =
                           Js.to_string Dom_html.window##.location##.hash
                         in
                         if hash = "#submissions" then "active" else "" )
                      ; "py-3"
                      ; "border-bottom"
                      ; "rounded-0" ]
                  ; Unsafe.string_attrib "data-bs-toggle" "tooltip"
                  ; Unsafe.string_attrib "data-bs-placement" "right"
                  ; a_aria "label" ["Submissions"]
                  ; a_title "This is the status board"
                  ; Unsafe.string_attrib "data-bs-original-title"
                      "Submissions" ]
                [table_icon] ]
        ; li
            [ a
                ~a:
                  [ a_href "#switch-contest"
                  ; a_class
                      [ "nav-link"
                      ; (let hash =
                           Js.to_string Dom_html.window##.location##.hash
                         in
                         if hash = "#switch-contest" then "active" else "" )
                      ; "py-3"
                      ; "border-bottom"
                      ; "rounded-0" ]
                  ; Unsafe.string_attrib "data-bs-toggle" "tooltip"
                  ; Unsafe.string_attrib "data-bs-placement" "right"
                  ; a_aria "label" ["Switch Contest"]
                  ; a_title "This is the contest switcher"
                  ; Unsafe.string_attrib "data-bs-original-title"
                      "Switch Contest" ]
                [arrow_left_right] ] ]
    ; div
        ~a:
          [ a_class ["dropdown"; "border-top"]
          ; a_style
              "position: fixed; bottom: 0; left: 0; width: 4.5rem; z-index: \
               1000;" ]
        [ a
            ~a:
              [ a_href "#"
              ; a_class
                  [ "d-flex"
                  ; "align-items-center"
                  ; "justify-content-center"
                  ; "p-3"
                  ; "link-body-emphasis"
                  ; "text-decoration-none"
                  ; "dropdown-toggle" ]
              ; Unsafe.string_attrib "data-bs-toggle" "dropdown"
              ; Unsafe.string_attrib "aria-expanded" "false" ]
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
                      "width:24px; height:24px; font-size:0.7rem; \
                       font-weight:600;" ]
                [txt (initials ())] ]
        ; (let dropdown_item ?(href = "#") label =
             li [a ~a:[a_class ["dropdown-item"]; a_href href] [txt label]]
           in
           let dropdown_divider () =
             li [hr ~a:[a_class ["dropdown-divider"]] ()]
           in
           ul
             ~a:
               [a_class ["dropdown-menu"; "text-small"; "shadow"]; a_style ""]
             [ dropdown_item "Settings"
             ; dropdown_divider ()
             ; dropdown_item "Sign out" ] ) ] ]

let full_sidebar () =
  let current_hash = Js.to_string Dom_html.window##.location##.hash in
  let nav_link href label icon =
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
            ; "px-3"
            ; "py-2"
            ; "border-bottom"
            ; "rounded-0" ]
        ; Unsafe.string_attrib "data-bs-toggle" "tooltip"
        ; Unsafe.string_attrib "data-bs-placement" "right"
        ; a_aria "label" [label]
        ; a_title label
        ; Unsafe.string_attrib "data-bs-original-title" label ]
      [icon; span ~a:[a_class ["ms-2"]] [txt label]]
  in
  div
    ~a:
      [ a_class ["d-flex"; "flex-column"; "flex-shrink-0"; "bg-body-tertiary"]
      ; a_style "width: 14rem; height: 100vh;" ]
    [ (* Top logo *)
      a
        ~a:
          [ a_href "#about"
          ; a_class
              [ "d-flex"
              ; "align-items-center"
              ; "p-3"
              ; "link-body-emphasis"
              ; "text-decoration-none" ]
          ; Unsafe.string_attrib "data-bs-toggle" "tooltip"
          ; Unsafe.string_attrib "data-bs-placement" "right"
          ; Unsafe.string_attrib "data-bs-original-title" "Full Sidebar" ]
        [ img ~src:"yoda2.png" ~alt:"Yoda Logo"
            ~a:[a_class ["yoda-logo"]; a_width 40]
            ()
        ; span ~a:[a_class ["ms-2"; "fs-5"; "fw-bold"]] [txt "YodaApp"] ]
      (* Nav items *)
    ; ul
        ~a:[a_class ["nav"; "nav-pills"; "flex-column"; "mb-auto"]]
        [ li
            ~a:[a_class ["nav-item"]]
            [nav_link "#dashboard" "Dashboard" dashboard_icon]
        ; li
            ~a:[a_class ["nav-item"]]
            [nav_link "#codeboard" "Codeboard" journal_code_icon]
        ; li
            ~a:[a_class ["nav-item"]]
            [nav_link "#submissions" "Submissions" table_icon]
        ; li
            ~a:[a_class ["nav-item"]]
            [nav_link "#switch-contest" "Switch Contest" arrow_left_right] ]
      (* Bottom dropdown *)
    ; div
        ~a:
          [ a_class ["dropdown"; "border-top"]
          ; a_style "margin-top:auto; padding-bottom:1rem;" ]
        [ a
            ~a:
              [ a_href "#"
              ; a_class
                  [ "d-flex"
                  ; "align-items-center"
                  ; "justify-content-start"
                  ; "px-3"
                  ; "py-2"
                  ; "link-body-emphasis"
                  ; "text-decoration-none"
                  ; "dropdown-toggle" ]
              ; Unsafe.string_attrib "data-bs-toggle" "dropdown"
              ; Unsafe.string_attrib "aria-expanded" "false" ]
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
                      "width:32px; height:32px; font-size:0.9rem; \
                       font-weight:600;" ]
                [txt (initials ())]
            ; span ~a:[a_class ["ms-2"]] [txt (Helpers.username ())] ]
        ; (let dropdown_item ?(href = "#") label =
             li [a ~a:[a_class ["dropdown-item"]; a_href href] [txt label]]
           in
           let dropdown_divider () =
             li [hr ~a:[a_class ["dropdown-divider"]] ()]
           in
           ul
             ~a:[a_class ["dropdown-menu"; "text-small"; "shadow"]]
             [ dropdown_item "Settings"
             ; dropdown_divider ()
             ; dropdown_item "Sign out" ] ) ] ]

let sidebar () =
  if Helpers.is_mobile () then div []
  else if Helpers.is_wide_desktop () then full_sidebar ()
  else icon_only_sidebar ()
