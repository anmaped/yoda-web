open Js_of_ocaml_tyxml
open Tyxml_js.Html

(* Function to generate a table row for a problem *)
let problem_row id name =
  tr
    [ td ~a:[a_class ["ps-3"]] [txt id]
    ; td ~a:[a_class ["p-0"]]
        [a ~a:[a_href ("#show-problem-" ^ id); a_class ["d-block"; "p-0"; "m-0"]] [txt name]]
    ]

(* Main content function generating the table *)
let content () =
  section
    ~a:[a_class ["panel-section"; "container"; "py-3"]]
    [ div
        ~a:[a_class ["card"; "shadow-sm"]]
        [ div
            ~a:[a_class ["card-header"; "bg-white"]]
            [h2 ~a:[a_class ["h5"; "mb-0"]] [txt "Problems"]]
        ; div
            ~a:[a_class ["table-responsive"]]
            [ table
                ~a:
                  [ a_class
                      [ "table"
                      ; "table-striped"
                      ; "table-hover"
                      ; "mb-0"
                      ; "align-middle" ] ]
                ~thead:
                  (thead
                     ~a:[a_class ["table-light"]]
                     [tr [th [txt "ID"]; th [txt "Problem"]]] )
                [ problem_row "pA" "Warmup"
                ; problem_row "pB" "Arrays"
                ; problem_row "pC" "Graphs"
                ; problem_row "pD" "DP"
                ; problem_row "pE" "Strings" ] ] ] ]
