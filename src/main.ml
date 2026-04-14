open Js_of_ocaml
open Js_of_ocaml_tyxml
open Tyxml_js.Html
open Tyxml_js.Html

let navigate_to path =
  Dom_html.window##.history##pushState
    Js.null (Js.string "")
    (Js.Opt.return (Js.string path)) ;
  Dom_html.window##.location##reload

(* Inject CSS from string *)
let inject_css css_str =
  let style = Dom_html.createStyle Dom_html.document in
  style##.textContent := Js.some (Js.string css_str) ;
  Dom.appendChild Dom_html.document##.head style

let () =
  Helpers.set_session_variable "username" "Joe Toe" ;
  Helpers.set_session_variable "contest_id" "1" ;
  (* Read CSS from file at compile-time *)
  let bootstrap_css = [%blob "bootstrap.css"] in
  inject_css bootstrap_css ;
  let codemirror_css = [%blob "codemirror.css"] in
  inject_css codemirror_css ;
  let style_css = [%blob "../static/style.css"] in
  inject_css style_css ;
  (* Get the app div where the content will be rendered *)
  let app_div = Dom_html.getElementById "app" in
  (* Function to render the page based on the URL hash *)
  let render_page () =
    let hash = Js.to_string Dom_html.window##.location##.hash in
    (* Clear the app div for rendering new content *)
    app_div##.innerHTML := Js.string "" ;
    app_div##.style##.height := Js.string "100%" ;
    app_div##.classList##add (Js.string "d-flex") ;
    app_div##.classList##add (Js.string "align-items-start") ;
    (* Determine the page to render based on hash *)
    let page =
      match hash with
      | "#login" ->
          [ Pages.Login.render
              ~on_success:(fun () -> navigate_to "#contests")
              () ]
      | "#users" -> [Pages.Users.render ()]
      | "#contests" -> [Pages.Contests.render ()]
      | p when Astring.String.is_prefix ~affix:"#show-problems" p ->
          [Pages.Problems.render ()]
      | p when Astring.String.is_prefix ~affix:"#scoreboard/" p ->
          let parts = Astring.String.cuts ~sep:"/" p in
          let contest_id = int_of_string (List.nth parts 1) in
          [Pages.Scoreboard.render ~contest_id ()]
      | "#dashboard" -> Pages.Dashboard.render ()
      | "#codeboard" ->
          List.iter
            (fun p -> Dom.appendChild app_div (Tyxml_js.To_dom.of_div p))
            (Pages.Codeboard.render ()) ;
          ignore (Pages.Codeboard.init ()) ;
          []
      | "#submissions" -> Pages.Submissions.render ()
      | p when Astring.String.is_prefix ~affix:"#show-problem-" p ->
          let parts = Astring.String.cuts ~sep:"-" p in
          let problem_id = List.nth parts 2 in
          [Pages.Problems.render ~problem_id ()]
      | _ -> Pages.Dashboard.render ()
      (* Default to Dashboard *)
    in
    (* Append the divs that need to be rendered *)
    List.iter
      (fun p -> Dom.appendChild app_div (Tyxml_js.To_dom.of_div p))
      page
  in
  (* Handle the hashchange event to respond to changes in the hash part of
     the URL *)
  Dom_html.window##.onhashchange
  := Dom.handler (fun _ -> render_page () ; Js._false) ;
  Dom_html.window##.onload :=
    Dom_html.handler (fun _ -> render_page () ; Js._false) ;
  Dom_html.window##.onresize
  := Dom_html.handler (fun _ -> render_page () ; Js._true) ;
  (* Initial page render when the app loads *)
  render_page ()
