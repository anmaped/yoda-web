open Js_of_ocaml_tyxml
open Tyxml_js.Html

let submission_row id problem lang result time =
  let badge_class =
    match result with
    | "Accepted" -> ["badge"; "text-bg-success"]
    | "Wrong Answer" -> ["badge"; "text-bg-danger"]
    | _ -> ["badge"; "text-bg-secondary"]
  in
  tr
    [ td ~a:[a_class ["ps-3"]] [txt id]
    ; td [txt problem]
    ; td [txt lang]
    ; td [span ~a:[a_class badge_class] [txt result]]
    ; td [txt time] ]

let content () =
  section
    ~a:[a_class ["panel-section"; "container"; "py-3"]]
    [ div
        ~a:[a_class ["card"; "shadow-sm"]]
        [ div
            ~a:[a_class ["card-header"; "bg-white"]]
            [h2 ~a:[a_class ["h5"; "mb-0"]] [txt "Recent Submissions"]]
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
                     [ tr
                         [ th [txt "#"]
                         ; th [txt "Problem"]
                         ; th [txt "Language"]
                         ; th [txt "Result"]
                         ; th [txt "Time"] ] ] )
                [ submission_row "1542" "A" "OCaml" "Accepted" "00:00:12"
                ; submission_row "1539" "B" "C++17" "Wrong Answer" "00:00:08"
                ; submission_row "1538" "C" "Python 3" "Accepted" "00:00:25"
                ; submission_row "1537" "D" "Java 17" "Runtime Error"
                    "00:01:03"
                ; submission_row "1536" "E" "Rust" "Time Limit Exceeded"
                    "00:02:00"
                ; submission_row "1535" "F" "Go" "Accepted" "00:00:40"
                ; submission_row "1534" "G" "Kotlin" "Wrong Answer"
                    "00:00:31"
                ; submission_row "1533" "H" "C# 10" "Accepted" "00:00:19"
                ; submission_row "1532" "I" "JavaScript" "Compilation Error"
                    "00:00:05"
                ; submission_row "1531" "J" "Swift" "Accepted" "00:00:52"
                ; submission_row "1530" "K" "Haskell" "Wrong Answer"
                    "00:00:27"
                ; submission_row "1529" "L" "OCaml" "Accepted" "00:00:14" ]
            ] ] ]
