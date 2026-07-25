open Js_of_ocaml
open Js_of_ocaml_tyxml

(* Inject CSS from string *)
let inject_css css_str =
  let style = Dom_html.createStyle Dom_html.document in
  style##.textContent := Js.some (Js.string css_str) ;
  Dom.appendChild Dom_html.document##.head style

let () =
  I18n.init () ;
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
    (* update title with current hash *)
    Dom_html.document##.title := Js.string (hash ^ " - "^I18n.t "sidebar_app_name") ;
    (* Clear the app div for rendering new content *)
    app_div##.innerHTML := Js.string "" ;
    app_div##.style##.height := Js.string "100%" ;
    app_div##.classList##add (Js.string "d-flex") ;
    app_div##.classList##add (Js.string "align-items-start") ;
    (* track hash changes *)
    Pages.Settings.save_referrer () ;
    (* Determine the page to render based on hash *)
    let page =
      match hash with
      | "#login" ->
          [ Pages.Login.render
              ~on_success:(fun () -> Helpers.navigate_to "#contests")
              () ]
      | "#logout" ->
          Helpers.remove_session_variable "token" ;
          Helpers.remove_cookies_variable "dream.session" ;
          Helpers.navigate_to "#login" ;
          []
      | "#users" -> [Pages.Users.render ()]
      | "#contests" -> Pages.Contests.render ()
      | p when Astring.String.is_prefix ~affix:"#show-problems" p ->
          Pages.Problems.render ()
      | p when Astring.String.is_prefix ~affix:"#scoreboard/" p ->
          let parts = Astring.String.cuts ~sep:"/" p in
          let contest_id = int_of_string (List.nth parts 1) in
          [Pages.Scoreboard.render ~contest_id ()]
      | "#dashboard" -> Pages.Dashboard.render ()
      | "#codeboard" ->
          List.iter
            (fun p -> Dom.appendChild app_div (Tyxml_js.To_dom.of_div p))
            (Pages.Codeboard.render ()) ;
          ignore Components.Editor.editor##refresh ;
          []
      | "#submissions" -> Pages.Submissions.render ()
      | p when Astring.String.is_prefix ~affix:"#show-problem-" p ->
          let parts = Astring.String.cuts ~sep:"-" p in
          let problem_id = List.nth parts 2 in
          Pages.Problems.render
            ~contest_id:(Helpers.get_current_contest_id ())
            ~problem_id ()
      | p when Astring.String.is_prefix ~affix:"#settings" p ->
          let parts = Astring.String.cuts ~sep:"-" p in
          if List.length parts <= 1 then [Pages.Settings.render ()]
          else
            let id = List.nth parts 1 in
            [Pages.Settings.render ~tab:id ()]
          (* Defaults to login *)
      | _ ->
          [ Pages.Login.render
              ~on_success:(fun () -> Helpers.navigate_to "#contests")
              () ]
        (* save last 10 previous hash *)
    in
    (* Append the divs that need to be rendered *)
    List.iter
      (fun p -> Dom.appendChild app_div (Tyxml_js.To_dom.of_div p))
      page
  in
  (* Handle the hashchange event to respond to changes in the hash part of
     the URL *)
  Dom_html.window##.onhashchange
  := Dom.handler (fun _ ->
      Console.console##log (Js.string "Hash changed") ;
      render_page () ;
      Js._false ) ;
  Dom_html.window##.onload :=
    Dom_html.handler (fun _ ->
        Console.console##log (Js.string "Page loaded") ;
        render_page () ;
        Js._false ) ;
  Dom_html.window##.onresize
  := Dom_html.handler (fun _ ->
      Console.console##log (Js.string "Window resized") ;
      render_page () ;
      Js._false ) ;
  let _ =
    (* Listen for the "render" event *)
    Dom_html.addEventListener Dom_html.window (Dom.Event.make "render")
      (Dom_html.handler (fun _ ->
           Console.console##log (Js.string "Render event triggered") ;
           render_page () ;
           Js._false ) )
      Js._false
  in
  ()
