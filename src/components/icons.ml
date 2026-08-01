open Js_of_ocaml_tyxml
open Tyxml_js.Svg

let terminal_fill_icon () =
  let open Tyxml_js.Svg in
  Tyxml_js.Html.svg
    ~a:
      [ a_class ["bi"; "bi-x-square-fill"]
      ; a_width (24., Some `Px)
      ; a_height (24., Some `Px)
      ; a_fill (`Color ("currentColor", None))
      ; a_viewBox (-0., -0., 16., 16.) ]
    [ path
        ~a:
          [ a_d
              "M0 3a2 2 0 0 1 2-2h12a2 2 0 0 1 2 2v10a2 2 0 0 1-2 2H2a2 2 0 \
               0 1-2-2zm9.5 5.5h-3a.5.5 0 0 0 0 1h3a.5.5 0 0 0 \
               0-1m-6.354-.354a.5.5 0 1 0 .708.708l2-2a.5.5 0 0 0 \
               0-.708l-2-2a.5.5 0 1 0-.708.708L4.793 6.5z" ]
        [] ]

let save_icon () =
  let open Tyxml_js.Svg in
  Tyxml_js.Html.svg
    ~a:
      [ a_width (16., Some `Px)
      ; a_height (16., Some `Px)
      ; a_class ["bi"; "bi-save"]
      ; a_fill (`Color ("currentColor", None))
      ; a_viewBox (0., 0., 16., 16.) ]
    [ path
        ~a:
          [ a_d
              "M2 1a1 1 0 0 0-1 1v12a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1V2a1 1 0 \
               0 0-1-1H9.5a1 1 0 0 0-1 1v7.293l2.646-2.647a.5.5 0 0 1 \
               .708.708l-3.5 3.5a.5.5 0 0 1-.708 0l-3.5-3.5a.5.5 0 1 1 \
               .708-.708L7.5 9.293V2a2 2 0 0 1 2-2H14a2 2 0 0 1 2 2v12a2 2 \
               0 0 1-2 2H2a2 2 0 0 1-2-2V2a2 2 0 0 1 2-2h2.5a.5.5 0 0 1 0 \
               1z" ]
        [] ]

let dashboard_icon () =
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

let journal_code_icon () =
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

let table_icon () =
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

let arrow_left_right () =
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

let gear_icon () =
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

let box_arrow_right_icon () =
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

let plus_square_icon () =
  let open Tyxml_js.Svg in
  Tyxml_js.Html.svg
    ~a:
      [ a_class ["bi"; "bi-plus-square"]
      ; a_width (32., Some `Px)
      ; a_height (32., Some `Px)
      ; a_fill (`Color ("currentColor", None))
      ; a_viewBox (-0., -0., 16., 16.) ]
    [ path
        ~a:
          [ a_d
              "M14 1a1 1 0 0 1 1 1v12a1 1 0 0 1-1 1H2a1 1 0 0 1-1-1V2a1 1 0 \
               0 1 1-1zM2 0a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h12a2 2 0 0 0 \
               2-2V2a2 2 0 0 0-2-2z" ]
        []
    ; path
        ~a:
          [ a_d
              "M8 4a.5.5 0 0 1 .5.5v3h3a.5.5 0 0 1 0 1h-3v3a.5.5 0 0 1-1 \
               0v-3h-3a.5.5 0 0 1 0-1h3v-3A.5.5 0 0 1 8 4" ]
        [] ]

let x_square_fill () =
  let open Tyxml_js.Svg in
  Tyxml_js.Html.svg
    ~a:
      [ a_class ["bi"; "bi-x-square-fill"]
      ; a_width (24., Some `Px)
      ; a_height (24., Some `Px)
      ; a_fill (`Color ("currentColor", None))
      ; a_viewBox (-0., -0., 16., 16.) ]
    [ path
        ~a:
          [ a_d
              "M2 0a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V2a2 2 0 \
               0 0-2-2zm3.354 4.646L8 7.293l2.646-2.647a.5.5 0 0 1 \
               .708.708L8.707 8l2.647 2.646a.5.5 0 0 1-.708.708L8 \
               8.707l-2.646 2.647a.5.5 0 0 1-.708-.708L7.293 8 4.646 \
               5.354a.5.5 0 1 1 .708-.708" ]
        [] ]

let download_icon () =
  Tyxml_js.Html.svg
    ~a:
      [ a_class ["bi"; "bi-download"; "me-1"]
      ; a_width (16., Some `Px)
      ; a_height (16., Some `Px)
      ; a_viewBox (-0., -0., 16., 16.)
      ; a_fill (`Color ("currentColor", None)) ]
    [ path
        ~a:
          [ a_d
              "M.5 9.9a.5.5 0 0 1 .5.5v2.5a1 1 0 0 0 1 1h12a1 1 0 0 0 \
               1-1v-2.5a.5.5 0 0 1 1 0v2.5a2 2 0 0 1-2 2H2a2 2 0 0 \
               1-2-2v-2.5a.5.5 0 0 1 .5-.5" ]
        []
    ; path
        ~a:
          [ a_d
              "M7.646 11.854a.5.5 0 0 0 .708 0l3-3a.5.5 0 0 0-.708-.708L8.5 \
               10.293V1.5a.5.5 0 0 0-1 0v8.793L5.354 8.146a.5.5 0 1 \
               0-.708.708z" ]
        [] ]

let clipboard_icon () =
  Tyxml_js.Html.svg
    ~a:
      [ a_class ["bi"; "bi-clipboard"; "me-1"]
      ; a_width (16., Some `Px)
      ; a_height (16., Some `Px)
      ; a_viewBox (-0., -0., 16., 16.)
      ; a_fill (`Color ("currentColor", None)) ]
    [ path
        ~a:
          [ a_d
              "M4 1.5H3a2 2 0 0 0-2 2V14a2 2 0 0 0 2 2h10a2 2 0 0 0 \
               2-2V3.5a2 2 0 0 0-2-2h-1v1h1a1 1 0 0 1 1 1V14a1 1 0 0 1-1 \
               1H3a1 1 0 0 1-1-1V3.5a1 1 0 0 1 1-1h1z" ]
        []
    ; path
        ~a:
          [ a_d
              "M9.5 1a.5.5 0 0 1 .5.5v1a.5.5 0 0 1-.5.5h-3a.5.5 0 0 \
               1-.5-.5v-1a.5.5 0 0 1 .5-.5zm-3-1A1.5 1.5 0 0 0 5 1.5v1A1.5 \
               1.5 0 0 0 6.5 4h3A1.5 1.5 0 0 0 11 2.5v-1A1.5 1.5 0 0 0 9.5 \
               0z" ]
        [] ]

let list_ul_icon ?(a = []) () =
  Tyxml_js.Html.svg
    ~a:
      [ a_class (["bi"; "bi-list-ul"] @ a)
      ; a_width (16., Some `Px)
      ; a_height (16., Some `Px)
      ; a_viewBox (0., 0., 16., 16.)
      ; a_fill (`Color ("currentColor", None)) ]
    [ path
        ~a:
          [ a_fill_rule `Evenodd
          ; a_d
              "M5 11.5a.5.5 0 0 1 .5-.5h9a.5.5 0 0 1 0 1h-9a.5.5 0 0 \
               1-.5-.5m0-4a.5.5 0 0 1 .5-.5h9a.5.5 0 0 1 0 1h-9a.5.5 0 0 \
               1-.5-.5m0-4a.5.5 0 0 1 .5-.5h9a.5.5 0 0 1 0 1h-9a.5.5 0 0 \
               1-.5-.5m-3 1a1 1 0 1 0 0-2 1 1 0 0 0 0 2m0 4a1 1 0 1 0 0-2 1 \
               1 0 0 0 0 2m0 4a1 1 0 1 0 0-2 1 1 0 0 0 0 2" ]
        [] ]

let pencil_icon () =
  Tyxml_js.Html.svg
    ~a:
      [ a_class ["bi"; "bi-pencil-square"]
      ; a_width (16., Some `Px)
      ; a_height (16., Some `Px)
      ; a_viewBox (0., 0., 16., 16.)
      ; a_fill (`Color ("currentColor", None)) ]
    [ path
        ~a:
          [ a_d
              "M15.502 1.94a.5.5 0 0 1 0 .706L14.459 \
               3.69l-2-2L13.502.646a.5.5 0 0 1 .707 0l1.293 1.293zm-1.75 \
               2.456-2-2L4.939 9.21a.5.5 0 0 0-.121.196l-.805 2.414a.25.25 \
               0 0 0 .316.316l2.414-.805a.5.5 0 0 0 .196-.12l6.813-6.814z" ]
        []
    ; path
        ~a:
          [ a_fill_rule `Evenodd
          ; a_d
              "M1 13.5A1.5 1.5 0 0 0 2.5 15h11a1.5 1.5 0 0 0 \
               1.5-1.5v-6a.5.5 0 0 0-1 0v6a.5.5 0 0 1-.5.5h-11a.5.5 0 0 \
               1-.5-.5v-11a.5.5 0 0 1 .5-.5H9a.5.5 0 0 0 0-1H2.5A1.5 1.5 0 \
               0 0 1 2.5z" ]
        [] ]

let trash_icon () =
  Tyxml_js.Html.svg
    ~a:
      [ a_class ["bi"; "bi-trash"]
      ; a_width (16., Some `Px)
      ; a_height (16., Some `Px)
      ; a_viewBox (0., 0., 16., 16.)
      ; a_fill (`Color ("currentColor", None)) ]
    [ path
        ~a:
          [ a_d
              "M5.5 5.5A.5.5 0 0 1 6 6v6a.5.5 0 0 1-1 0V6a.5.5 0 0 1 \
               .5-.5m2.5 0a.5.5 0 0 1 .5.5v6a.5.5 0 0 1-1 0V6a.5.5 0 0 1 \
               .5-.5m3 .5a.5.5 0 0 0-1 0v6a.5.5 0 0 0 1 0z" ]
        []
    ; path
        ~a:
          [ a_d
              "M14.5 3a1 1 0 0 1-1 1H13v9a2 2 0 0 1-2 2H5a2 2 0 0 \
               1-2-2V4h-.5a1 1 0 0 1-1-1V2a1 1 0 0 1 1-1H6a1 1 0 0 1 \
               1-1h2a1 1 0 0 1 1 1h3.5a1 1 0 0 1 1 1zM4.118 4 4 4.059V13a1 \
               1 0 0 0 1 1h6a1 1 0 0 0 1-1V4.059L11.882 4zM2.5 3h11V2h-11z"
          ]
        [] ]

let inbox_icon () =
  Tyxml_js.Html.svg
    ~a:
      [ a_class ["bi"; "bi-inbox"]
      ; a_width (16., Some `Px)
      ; a_height (16., Some `Px)
      ; a_viewBox (-0., -0., 16., 16.)
      ; a_fill (`Color ("currentColor", None)) ]
    [ path
        ~a:
          [ a_d
              "M4.98 4a.5.5 0 0 0-.39.188L1.54 8H6a.5.5 0 0 1 .5.5 1.5 1.5 \
               0 1 0 3 0A.5.5 0 0 1 10 8h4.46l-3.05-3.812A.5.5 0 0 0 11.02 \
               4zm9.954 5H10.45a2.5 2.5 0 0 1-4.9 0H1.066l.32 2.562a.5.5 0 \
               0 0 .497.438h12.234a.5.5 0 0 0 .496-.438zM3.809 3.563A1.5 \
               1.5 0 0 1 4.981 3h6.038a1.5 1.5 0 0 1 1.172.563l3.7 \
               4.625a.5.5 0 0 1 .105.374l-.39 3.124A1.5 1.5 0 0 1 14.117 \
               13H1.883a1.5 1.5 0 0 1-1.489-1.314l-.39-3.124a.5.5 0 0 1 \
               .106-.374z" ]
        [] ]

let search_icon () =
  Tyxml_js.Html.svg
    ~a:
      [ a_class ["bi"; "bi-search"]
      ; a_width (16., Some `Px)
      ; a_height (16., Some `Px)
      ; a_viewBox (-0., -0., 16., 16.)
      ; a_fill (`Color ("currentColor", None)) ]
    [ path
        ~a:
          [ a_d
              "M11.742 10.344a6.5 6.5 0 1 0-1.397 \
               1.398h-.001q.044.06.098.115l3.85 3.85a1 1 0 0 0 \
               1.415-1.414l-3.85-3.85a1 1 0 0 0-.115-.1zM12 6.5a5.5 5.5 0 1 \
               1-11 0 5.5 5.5 0 0 1 11 0" ]
        [] ]

let plus_lg_icon ?(a = []) () =
  Tyxml_js.Html.svg
    ~a:
      [ a_class (["bi"; "bi-plus-lg"] @ a)
      ; a_width (16., Some `Px)
      ; a_height (16., Some `Px)
      ; a_viewBox (-0., -0., 16., 16.)
      ; a_fill (`Color ("currentColor", None)) ]
    [ path
        ~a:
          [ a_d
              "M8 2a.5.5 0 0 1 .5.5v5h5a.5.5 0 0 1 0 1h-5v5a.5.5 0 0 1-1 \
               0v-5h-5a.5.5 0 0 1 0-1h5v-5A.5.5 0 0 1 8 2" ]
        [] ]

(* this icon spins *)
let arrow_repeat_icon () =
  Tyxml_js.Html.svg
    ~a:
      [ a_class ["bi"; "bi-arrow-repeat"; "spin"]
      ; a_width (16., Some `Px)
      ; a_height (16., Some `Px)
      ; a_viewBox (-0., -0., 16., 16.)
      ; a_fill (`Color ("currentColor", None)) ]
    [ path
        ~a:
          [ a_d
              "M11.534 7h3.932a.25.25 0 0 1 .192.41l-1.966 2.36a.25.25 0 0 \
               1-.384 0l-1.966-2.36a.25.25 0 0 1 .192-.41m-11 \
               2h3.932a.25.25 0 0 0 .192-.41L2.692 6.23a.25.25 0 0 0-.384 \
               0L.342 8.59A.25.25 0 0 0 .534 9" ]
        []
    ; path
        ~a:
          [ a_d
              "M8 3c-1.552 0-2.94.707-3.857 1.818a.5.5 0 1 \
               1-.771-.636A6.002 6.002 0 0 1 13.917 7H12.9A5 5 0 0 0 8 \
               3M3.1 9a5.002 5.002 0 0 0 8.757 2.182.5.5 0 1 1 \
               .771.636A6.002 6.002 0 0 1 2.083 9z" ]
        [] ]

let arrow_clockwise_icon () =
  Tyxml_js.Html.svg
    ~a:
      [ a_class ["bi"; "bi-arrow-clockwise"; "me-1"]
      ; a_width (16., Some `Px)
      ; a_height (16., Some `Px)
      ; a_viewBox (-0., -0., 16., 16.)
      ; a_fill (`Color ("currentColor", None)) ]
    [ path
        ~a:
          [ a_d
              "M8 3a5 5 0 1 0 4.546 2.914.5.5 0 0 1 .908-.417A6 6 0 1 1 8 2z"
          ]
        []
    ; path
        ~a:
          [ a_fill_rule `Evenodd
          ; a_d
              "M8 4.466V.534a.25.25 0 0 1 .41-.192l2.36 1.966c.12.1 .12.284 \
               0 .384L8.41 4.658A.25.25 0 0 1 8 4.466" ]
        [] ]

let x_close_icon () =
  Tyxml_js.Html.svg
    ~a:
      [ a_class ["bi"; "bi-x-lg"]
      ; a_width (16., Some `Px)
      ; a_height (16., Some `Px)
      ; a_viewBox (-0., -0., 16., 16.)
      ; a_fill (`Color ("currentColor", None)) ]
    [ path
        ~a:
          [ Unsafe.string_attrib "d"
              "M2.146 2.854a.5.5 0 1 1 .708-.708L8 7.293l5.146-5.147a.5.5 0 \
               0 1 .708.708L8.707 8l5.147 5.146a.5.5 0 0 1-.708.708L8 \
               8.707l-5.146 5.147a.5.5 0 0 1-.708-.708L7.293 8z" ]
        [] ]

let shield_lock_icon () =
  Tyxml_js.Html.svg
    ~a:
      [ a_class ["bi"; "bi-shield-lock"]
      ; a_width (16., Some `Px)
      ; a_height (16., Some `Px)
      ; a_viewBox (-0., -0., 16., 16.)
      ; a_fill (`Color ("currentColor", None)) ]
    [ path
        ~a:
          [ Unsafe.string_attrib "d"
              "M5.338 1.59a61 61 0 0 0-2.837.856.48.48 0 0 0-.328.39c-.554 \
               4.157.726 7.19 2.253 9.188a10.7 10.7 0 0 0 2.287 \
               2.233c.346.244.652.42.893.533q.18.085.293.118a1 1 0 0 0 \
               .101.025 1 1 0 0 0 \
               .1-.025q.114-.034.294-.118c.24-.113.547-.29.893-.533a10.7 \
               10.7 0 0 0 2.287-2.233c1.527-1.997 2.807-5.031 \
               2.253-9.188a.48.48 0 0 \
               0-.328-.39c-.651-.213-1.75-.56-2.837-.855C9.552 1.29 8.531 \
               1.067 8 1.067c-.53 0-1.552.223-2.662.524zM5.072.56C6.157.265 \
               7.31 0 8 0s1.843.265 2.928.56c1.11.3 2.229.655 2.887.87a1.54 \
               1.54 0 0 1 1.044 1.262c.596 4.477-.787 7.795-2.465 9.99a11.8 \
               11.8 0 0 1-2.517 2.453 7 7 0 0 \
               1-1.048.625c-.28.132-.581.24-.829.24s-.548-.108-.829-.24a7 7 \
               0 0 1-1.048-.625 11.8 11.8 0 0 1-2.517-2.453C1.928 \
               10.487.545 7.169 1.141 2.692A1.54 1.54 0 0 1 2.185 1.43 63 \
               63 0 0 1 5.072.56" ]
        []
    ; path
        ~a:
          [ Unsafe.string_attrib "d"
              "M9.5 6.5a1.5 1.5 0 0 1-1 1.415l.385 1.99a.5.5 0 0 \
               1-.491.595h-.788a.5.5 0 0 1-.49-.595l.384-1.99a1.5 1.5 0 1 1 \
               2-1.415" ]
        [] ]
