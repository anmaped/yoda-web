let render () =
  let contest_id = Helpers.get_current_contest_id () in
  match Helpers.layout () with
  | Helpers.Mobile ->
      [ Js_of_ocaml_tyxml.Tyxml_js.Html.div
          [ Components.Sidebar.sidebar ~mobile:true ()
          ; Components.View_summary.content ~contest_id () ] ]
  | Helpers.Normal ->
      [ Components.Sidebar.sidebar ~wide:false ()
      ; Components.View_summary.content ~contest_id () ]
  | Helpers.Wide ->
      [ Components.Sidebar.sidebar ()
      ; Components.View_summary.content ~contest_id () ]
