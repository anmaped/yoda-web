open Js_of_ocaml

let bootstrap_css = [%blob "bootstrap.css"]

let codemirror_css = [%blob "../static/editor.css"]

let style_css = [%blob "../static/style.css"]

let yoda_logo = [%blob "../static/yoda.png"]

(* Inject CSS from string *)
let inject_css css_str =
  let style = Dom_html.createStyle Dom_html.document in
  style##.textContent := Js.some (Js.string css_str) ;
  Dom.appendChild Dom_html.document##.head style

let init () =
  (* Inject CSS files at compile-time *)
  inject_css bootstrap_css ; inject_css codemirror_css ; inject_css style_css

let yoda_logo_url =
  let byte_values =
    Array.init (String.length yoda_logo) (fun i -> Char.code yoda_logo.[i])
  in
  let uint8 =
    new%js Typed_array.uint8Array_fromArray (Js.array byte_values)
  in
  let blob =
    File.blob_from_any ~contentType:"image/png"
      [`arrayBufferView (uint8 :> Typed_array.arrayBufferView Js.t)]
  in
  Js.to_string (Dom_html.window##._URL##createObjectURL blob)

let yoda_cameling_gif = [%blob "../static/yoda-cameling-loop.gif"]

let yoda_cameling_gif_url =
  let byte_values =
    Array.init (String.length yoda_cameling_gif) (fun i ->
        Char.code yoda_cameling_gif.[i] )
  in
  let uint8 =
    new%js Typed_array.uint8Array_fromArray (Js.array byte_values)
  in
  let blob =
    File.blob_from_any ~contentType:"image/gif"
      [`arrayBufferView (uint8 :> Typed_array.arrayBufferView Js.t)]
  in
  Js.to_string (Dom_html.window##._URL##createObjectURL blob)
