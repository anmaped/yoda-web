open Js_of_ocaml_tyxml
open Tyxml_js.Html

(* Function to generate a table row for a problem *)
let problem_row id code title =
  let row_class =
    match id with
    | Some problem_id
      when List.mem problem_id
             (Model.Problem_state.get_viewed_problem_ids ()) ->
        []
    | _ -> ["problem-list-item-unselected"]
  in
  tr
    ~a:[a_class row_class]
    [ td ~a:[a_class ["ps-3"]] [txt code]
    ; td
        ~a:[a_class ["p-0"]]
        [ a
            ~a:[a_href ("#show-problem-" ^ code); a_class ["p-0"; "m-0"]]
            [txt title] ] ]

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
           [ tr
               [ th [txt (I18n.t "problems_col_id")]
               ; th [txt (I18n.t "problems_col_name")] ] ] )
      []
  in
  let tbody =
    Js_of_ocaml.Dom_html.createTbody Js_of_ocaml.Dom_html.document
  in
  Js_of_ocaml.Dom.appendChild (Tyxml_js.To_dom.of_table tbl) tbody ;
  Problem_list.content ~contest_id:current_selected_contest ~problem_row
    ~tbody () ;
  section
    ~a:[a_class ["panel-section"; "container"; "py-3"]]
    [ div
        ~a:[a_class ["card"; "shadow-sm"]]
        [ div
            ~a:[a_class ["card-header"]]
            [h2 ~a:[a_class ["h5"; "mb-0"]] [txt (I18n.t "problems_title")]]
        ; div ~a:[a_class ["table-responsive"]] [tbl] ] ]
