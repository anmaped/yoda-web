open Js_of_ocaml
open Js_of_ocaml_tyxml
open Tyxml_js.Html

type config =
  {endpoint: string; model: string; api_key: string; prompt: string}

let key_endpoint = "yoda-settings-llm-endpoint"

let key_model = "yoda-settings-llm-model"

let key_api_key = "yoda-settings-llm-api-key"

let key_prompt = "yoda-settings-llm-prompt"

let storage_key key = key ^ "-" ^ Helpers.get_username ()

let endpoint = ref ""

let model = ref ""

let api_key = ref ""

let prompt =
  ref
    "Review this source file as a judging aid. Describe notable patterns \
     and possible signs of generated code, with uncertainty; never claim to \
     prove authorship. Consider the number of attempts supplied. Respond \
     concisely with evidence and caveats."

let init () =
  List.iter
    (fun (key, value) ->
      match Helpers.get_local_variable (storage_key key) with
      | Some saved -> value := Js.to_string saved
      | None -> () )
    [ (key_endpoint, endpoint)
    ; (key_model, model)
    ; (key_api_key, api_key)
    ; (key_prompt, prompt) ]

let configuration () =
  if !endpoint = "" || !model = "" || !api_key = "" || !prompt = "" then None
  else
    Some
      {endpoint= !endpoint; model= !model; api_key= !api_key; prompt= !prompt}

let text_input title key value typ =
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
                Helpers.set_local_variable (storage_key key) !value ;
                false ) ]
        () ]

let render_tab () =
  Settings_helpers.section_card
    (I18n.t "settings_llm_evaluation")
    [ p
        ~a:[a_class ["text-muted"]]
        [ txt
            "Optional judging aid, not an authorship detector. Source code \
             and attempt metadata are sent to your chosen provider only \
             when you click Evaluate on the Judge board. Settings, \
             including your API key, are saved in this browser's local \
             storage. Use a trusted device. Browser access requires \
             provider CORS support; use a trusted server proxy otherwise." ]
    ; div
        ~a:[a_class ["row"]]
        [ div
            ~a:[a_class ["col-md-5"]]
            [ text_input "OpenAI-compatible chat completions URL"
                key_endpoint endpoint `Text ]
        ; div
            ~a:[a_class ["col-md-3"]]
            [text_input "Model" key_model model `Text]
        ; div
            ~a:[a_class ["col-md-4"]]
            [text_input "API key" key_api_key api_key `Password] ]
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
                    Helpers.set_local_variable (storage_key key_prompt)
                      !prompt ;
                    false ) ]
            (txt !prompt) ] ]
