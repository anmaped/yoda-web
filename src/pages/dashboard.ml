
let render () =
  let contest_id = Helpers.get_current_contest_id () in
  [Components.Sidebar.sidebar (); Components.View_summary.content ~contest_id ()]
