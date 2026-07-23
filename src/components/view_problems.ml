open Js_of_ocaml
open Js_of_ocaml_tyxml
open Tyxml_js.Html
open I18n
let t = t

(* Function to generate a table row for a problem *)
let problem_row id name =
  tr
    [ td ~a:[a_class ["ps-3"]] [txt id]
    ; td
        ~a:[a_class ["p-0"]]
        [ a
            ~a:
              [ a_href ("#show-problem-" ^ id)
              ; a_class ["d-block"; "p-0"; "m-0"] ]
            [txt name] ] ]

(* Main content function generating the table *)
let content () =
  let current_selected_contest = Helpers.get_current_contest_id () in
  let tbl =
    table
      ~a:
        [ a_class
            ["table"; "table-striped"; "table-hover"; "mb-0"; "align-middle"]
        ]
      ~thead:
        (thead
           ~a:[a_class ["table-light"]]
           [tr [th [txt (t "problems_col_id")]; th [txt (t "problems_col_name")]]] )
      []
  in
  Problem_list.content ~contest_id:current_selected_contest ~problem_row ~tbl
    () ;
  section
    ~a:[a_class ["panel-section"; "container"; "py-3"]]
    [ div
        ~a:[a_class ["card"; "shadow-sm"]]
        [ div
            ~a:[a_class ["card-header"; "bg-white"]]
            [h2 ~a:[a_class ["h5"; "mb-0"]] [txt (t "problems_title")]]
        ; div ~a:[a_class ["table-responsive"]] [tbl] ] ]
