open Js_of_ocaml
open Js_of_ocaml_lwt
open Js_of_ocaml_tyxml
open Tyxml_js.Html
open Lwt.Infix

let history_size = 32

let requests_per_sec_history : float list ref = ref []

let queued_jobs_per_sec_history : float list ref = ref []

let last_sample_ts_ms : float option ref = ref None

let last_requests_total : int option ref = ref None

let last_queued_total : int option ref = ref None

let rec drop n xs =
  if n <= 0 then xs
  else match xs with [] -> [] | _ :: tl -> drop (n - 1) tl

let push_history history_ref value =
  let next = !history_ref @ [value] in
  let overflow = List.length next - history_size in
  history_ref := if overflow > 0 then drop overflow next else next

let compute_delta_per_sec ~prev_total ~curr_total ~prev_ts_ms ~curr_ts_ms =
  let dt = (curr_ts_ms -. prev_ts_ms) /. 1000. in
  if dt <= 0. then 0. else float_of_int (curr_total - prev_total) /. dt

let add_sample ~req_total ~queue_total ~now_ms =
  ( match (!last_requests_total, !last_queued_total, !last_sample_ts_ms) with
  | Some prev_req, Some prev_queue, Some prev_ts ->
      let req_per_sec =
        compute_delta_per_sec ~prev_total:prev_req ~curr_total:req_total
          ~prev_ts_ms:prev_ts ~curr_ts_ms:now_ms
      in
      let queued_per_sec =
        compute_delta_per_sec ~prev_total:prev_queue ~curr_total:queue_total
          ~prev_ts_ms:prev_ts ~curr_ts_ms:now_ms
      in
      push_history requests_per_sec_history req_per_sec ;
      push_history queued_jobs_per_sec_history queued_per_sec
  | _ ->
      push_history requests_per_sec_history 0. ;
      push_history queued_jobs_per_sec_history 0. ) ;
  last_requests_total := Some req_total ;
  last_queued_total := Some queue_total ;
  last_sample_ts_ms := Some now_ms

let requests_values () = !requests_per_sec_history

let queued_values () = !queued_jobs_per_sec_history

let points_of_values ~width ~height ~pad values =
  let min_v = List.fold_left min infinity values in
  let max_v = List.fold_left max neg_infinity values in
  let span = max 0.000001 (max_v -. min_v) in
  let x_min = pad and x_max = float_of_int width -. pad in
  let y_min = pad and y_max = float_of_int height -. pad in
  let inner_w = max 1. (x_max -. x_min) in
  let inner_h = max 1. (y_max -. y_min) in
  let n = List.length values in
  let y_of v =
    let ratio = (v -. min_v) /. span in
    y_max -. (ratio *. inner_h)
  in
  let points =
    if n <= 1 then
      let y = y_of (List.hd values) in
      [(x_min, y); (x_max, y)]
    else
      List.mapi
        (fun i v ->
          let x =
            x_min +. (float_of_int i /. float_of_int (n - 1) *. inner_w)
          in
          let y = y_of v in
          (x, y) )
        values
  in
  (points, min_v, max_v)

let line_path_from_points points =
  match points with
  | [] -> ""
  | (x0, y0) :: tl ->
      let buf = Buffer.create 256 in
      Buffer.add_string buf (Printf.sprintf "M %.2f %.2f" x0 y0) ;
      List.iter
        (fun (x, y) ->
          Buffer.add_string buf (Printf.sprintf " L %.2f %.2f" x y) )
        tl ;
      Buffer.contents buf

let area_path_from_points ~height ~pad points =
  match points with
  | [] -> ""
  | (x0, y0) :: tl ->
      let y_base = float_of_int height -. pad in
      let last_x = List.fold_left (fun _ (x, _) -> x) x0 tl in
      let buf = Buffer.create 320 in
      Buffer.add_string buf (Printf.sprintf "M %.2f %.2f" x0 y_base) ;
      Buffer.add_string buf (Printf.sprintf " L %.2f %.2f" x0 y0) ;
      List.iter
        (fun (x, y) ->
          Buffer.add_string buf (Printf.sprintf " L %.2f %.2f" x y) )
        tl ;
      Buffer.add_string buf (Printf.sprintf " L %.2f %.2f Z" last_x y_base) ;
      Buffer.contents buf

let render_line_graph ~label ~values =
  let width = 320 and height = 62 in
  let pad = 5. in
  let last_value = List.fold_left (fun _ v -> v) 0. values in
  let values_for_plot = if values = [] then [0.] else values in
  let points, min_v, max_v =
    points_of_values ~width ~height ~pad values_for_plot
  in
  let line_d = line_path_from_points points in
  let area_d = area_path_from_points ~height ~pad points in
  let x0 = pad in
  let x1 = float_of_int width -. pad in
  let y_top = pad in
  let y_mid = float_of_int height /. 2. in
  let y_bottom = float_of_int height -. pad in
  let last_x, last_y = List.fold_left (fun _ p -> p) (x0, y_mid) points in
  div
    ~a:[Tyxml_js.Html.a_class ["stats-line-graph-wrap"; "mb-3"]]
    [ div
        ~a:[Tyxml_js.Html.a_class ["stats-line-graph-meta"]]
        [ span
            ~a:[Tyxml_js.Html.a_class ["stats-line-graph-label"]]
            [txt label]
        ; span
            ~a:[Tyxml_js.Html.a_class ["stats-line-graph-value"]]
            [ txt
                (Printf.sprintf "%.2f/s  (min %.2f / max %.2f)" last_value
                   min_v max_v ) ] ]
    ; Tyxml_js.Html.svg
        ~a:
          [ Tyxml_js.Svg.a_class ["stats-line-graph"]
          ; Tyxml_js.Svg.a_viewBox
              (0., 0., float_of_int width, float_of_int height) ]
        [ Tyxml_js.Svg.path
            ~a:
              [ Tyxml_js.Svg.a_d
                  (Printf.sprintf "M %.2f %.2f L %.2f %.2f" x0 y_top x1 y_top)
              ; Tyxml_js.Svg.a_class ["stats-line-graph-grid"] ]
            []
        ; Tyxml_js.Svg.path
            ~a:
              [ Tyxml_js.Svg.a_d
                  (Printf.sprintf "M %.2f %.2f L %.2f %.2f" x0 y_mid x1 y_mid)
              ; Tyxml_js.Svg.a_class ["stats-line-graph-grid"] ]
            []
        ; Tyxml_js.Svg.path
            ~a:
              [ Tyxml_js.Svg.a_d
                  (Printf.sprintf "M %.2f %.2f L %.2f %.2f" x0 y_bottom x1
                     y_bottom )
              ; Tyxml_js.Svg.a_class ["stats-line-graph-grid"] ]
            []
        ; Tyxml_js.Svg.path
            ~a:
              [ Tyxml_js.Svg.a_d area_d
              ; Tyxml_js.Svg.a_class ["stats-line-graph-area"] ]
            []
        ; Tyxml_js.Svg.path
            ~a:
              [ Tyxml_js.Svg.a_d line_d
              ; Tyxml_js.Svg.a_class ["stats-line-graph-path"] ]
            []
        ; Tyxml_js.Svg.circle
            ~a:
              [ Tyxml_js.Svg.a_cx (last_x, None)
              ; Tyxml_js.Svg.a_cy (last_y, None)
              ; Tyxml_js.Svg.a_r (2.6, None)
              ; Tyxml_js.Svg.a_class ["stats-line-graph-dot"] ]
            [] ] ]

let poll_started : bool ref = ref false

let stats_tab_is_visible () =
  let hash = Js.to_string Dom_html.window##.location##.hash in
  Astring.String.is_prefix ~affix:"#settings-stats" hash

let start_polling ~is_loading ~load_stats =
  if !poll_started then ()
  else (
    poll_started := true ;
    let rec loop () =
      Lwt_js.sleep 10.0
      >>= fun () ->
      if not (stats_tab_is_visible ()) then (
        poll_started := false ;
        Lwt.return_unit )
      else (
        if not (is_loading ()) then ignore (load_stats ()) ;
        loop () )
    in
    ignore (loop ()) )
