open Js_of_ocaml
open Js_of_ocaml_tyxml
open Tyxml_js.Html

type config =
  {endpoint: string; model: string; api_key: string; prompt: string}

let endpoint = ref ""

let model = ref ""

let api_key = ref ""

let clear_api_key () = api_key := ""

let prompt =
  ref
    "Review this source file as a judging aid. Describe notable patterns \
     and possible signs of generated code, with uncertainty; never claim to \
     prove authorship. Consider the number of attempts supplied. Respond \
     concisely with evidence and caveats."

let configuration () =
  if !endpoint = "" || !model = "" || !api_key = "" || !prompt = "" then None
  else
    Some
      {endpoint= !endpoint; model= !model; api_key= !api_key; prompt= !prompt}

let text_input title value typ =
  label
    ~a:[a_class ["d-block"; "mb-2"]]
    [ span [txt title]
    ; input
        ~a:
          [ a_class ["form-control"]
          ; a_input_type typ
          ; a_value !value
          ; a_oninput (fun event ->
                let target =
                  Js.Opt.get event##.target (fun () -> assert false)
                in
                let input =
                  Js.Opt.get (Dom_html.CoerceTo.input target) (fun () ->
                      assert false )
                in
                value := Js.to_string input##.value ;
                false ) ]
        () ]

let render_tab () =
  Settings_helpers.section_card (I18n.t "settings_llm_evaluation")
    [ p
        ~a:[a_class ["text-muted"]]
        [ txt
            "Optional judging aid, not an authorship detector. Source code \
             and attempt metadata are sent to your chosen provider only \
             when you click Evaluate on the Judge board. Settings are kept \
             in memory, never saved. Browser access requires provider CORS \
             support; use a trusted server proxy otherwise." ]
    ; div
        ~a:[a_class ["row"]]
        [ div
            ~a:[a_class ["col-md-5"]]
            [ text_input "OpenAI-compatible chat completions URL" endpoint
                `Text ]
        ; div ~a:[a_class ["col-md-3"]] [text_input "Model" model `Text]
        ; div
            ~a:[a_class ["col-md-4"]]
            [text_input "API key" api_key `Password] ]
    ; label
        ~a:[a_class ["d-block"; "mb-3"]]
        [ span [txt "Evaluation prompt"]
        ; textarea
            ~a:
              [ a_class ["form-control"]
              ; a_rows 4
              ; a_oninput (fun event ->
                    let target =
                      Js.Opt.get event##.target (fun () -> assert false)
                    in
                    let field =
                      Js.Opt.get (Dom_html.CoerceTo.textarea target)
                        (fun () -> assert false )
                    in
                    prompt := Js.to_string field##.value ;
                    false ) ]
            (txt !prompt) ] ]
