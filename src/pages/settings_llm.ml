open Js_of_ocaml
open Js_of_ocaml_tyxml
open Tyxml_js.Html
open Lwt.Infix

type config =
  {endpoint: string; model: string; api_key: string; prompt: string}

let key_endpoint = "yoda-settings-llm-endpoint"

let key_model = "yoda-settings-llm-model"

let key_api_key = "yoda-settings-llm-api-key"

let key_prompt = "yoda-settings-llm-prompt"

let storage_key key = key ^ "-" ^ Helpers.get_username ()

let endpoint = ref "/llm/v1/chat/completions"

let model = ref ""

let api_key = ref ""

let models = ref []

let models_loading = ref false

let models_error = ref ""

let loaded_for = ref None

let test_loading = ref false

let test_result : (bool * string) option ref = ref None

let test_generation = ref 0

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

let load_models () =
  let requested_endpoint = !endpoint and key = !api_key in
  if
    requested_endpoint <> "" && key <> ""
    && !loaded_for <> Some (requested_endpoint, key)
  then (
    loaded_for := Some (requested_endpoint, key) ;
    models_loading := true ;
    models_error := "" ;
    Lwt.async (fun () ->
        Lwt.catch
          (fun () ->
            Api.Openai.list_models ~endpoint:requested_endpoint
              ~api_key:key
            >>= fun available ->
            if !endpoint = requested_endpoint && !api_key = key then (
              models := available ;
              if not (List.mem !model available) then (
                model := "" ;
                Helpers.set_local_variable (storage_key key_model) "" ) ;
              models_error :=
                if available = [] then "Provider returned no models." else "" ;
              models_loading := false ;
              Helpers.trigger_render () ) ;
            Lwt.return_unit )
          (fun error ->
            if !endpoint = requested_endpoint && !api_key = key then (
              models_loading := false ;
              models_error :=
                ( match error with
                | Failure message -> message
                | _ ->
                    "Could not load models. Check the endpoint, API key and \
                     provider CORS support." ) ;
              Helpers.trigger_render () ) ;
            Lwt.return_unit ) ) )

let test_llm () =
  if not !test_loading && List.mem !model !models then (
    let requested_endpoint = !endpoint
    and key = !api_key
    and selected_model = !model
    and generation = !test_generation in
    test_loading := true ;
    test_result := None ;
    Helpers.trigger_render () ;
    Lwt.async (fun () ->
        let finish result =
          if generation = !test_generation then (
            test_loading := false ;
            test_result := Some result ;
            Helpers.trigger_render () ) ;
          Lwt.return_unit
        in
        Lwt.catch
          (fun () ->
            Api.Openai.chat_completion
              ~endpoint:requested_endpoint ~api_key:key
              ~model:selected_model ~messages:[("user", "Reply with OK.")]
            >>= fun content ->
            finish
              ( if String.trim content <> "" then
                  (true, "LLM ready: chat completion succeeded.")
                else (false, "Provider returned an empty response.") ) )
          (fun error ->
            finish
              ( false
              , ( match error with
                | Failure message -> message
                | _ ->
                    "Request failed. Check the endpoint, proxy or CORS \
                     policy, and network access." ) ) ) ) )

let text_input title key value typ =
  label
    ~a:[a_class ["d-block"; "mb-2"]]
    [ span [txt title]
    ; input
        ~a:
          ( [ a_class ["form-control"]
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
                models := [] ;
                models_loading := false ;
                models_error := "" ;
                loaded_for := None ;
                model := "" ;
                Helpers.set_local_variable (storage_key key_model) "" ;
                incr test_generation ;
                test_loading := false ;
                test_result := None ;
                false ) ]
          @ [a_onchange (fun _ -> Helpers.trigger_render () ; false)] )
        () ]

let render_tab () =
  load_models () ;
  Settings_helpers.section_card
    (I18n.t "settings_llm_evaluation")
    [ p
        ~a:[a_class ["text-muted"]]
        [ txt
            "Optional judging aid, not an authorship detector. Source code \
              and attempt metadata are sent to your chosen provider only \
              when you click Evaluate on the Judge board. Settings, \
              including your API key, are saved in this browser's local \
              storage. Use a trusted device. The default /llm/ endpoint \
              requires an nginx LLM_ROUTING_URL; direct provider URLs require \
              provider CORS support." ]
    ; div
        ~a:[a_class ["row"]]
        [ div
            ~a:[a_class ["col-md-5"]]
            [ text_input "OpenAI-compatible chat completions URL"
                key_endpoint endpoint `Text ]
        ; div
            ~a:[a_class ["col-md-5"]]
            [text_input "API key" key_api_key api_key `Password] ]
    ; div
        ~a:[a_class ["mb-3"]]
        [ label ~a:[a_class ["form-label"]] [txt "Model"]
        ; select
            ~a:
              ( [ a_class ["form-select"]
                ; a_onchange (fun event ->
                      let target =
                        Js.Opt.get
                          (Dom_html.CoerceTo.select
                             (Js.Opt.get event##.target (fun () ->
                                  assert false ) ) )
                          (fun () -> assert false)
                      in
                      model := Js.to_string target##.value ;
                      Helpers.set_local_variable (storage_key key_model)
                        !model ;
                      incr test_generation ;
                      test_loading := false ;
                      test_result := None ;
                      Helpers.trigger_render () ;
                      false ) ]
              @ if !models = [] then [a_disabled ()] else [] )
            ( option ~a:[a_value ""] (txt "Select a model")
            :: List.map
                 (fun id ->
                   option
                     ~a:
                       ( [a_value id]
                       @ if id = !model then [a_selected ()] else [] )
                     (txt id) )
                 !models )
        ; ( if !endpoint = "" || !api_key = "" then
              small
                ~a:[a_class ["text-muted"]]
                [txt "Enter an endpoint and API key to load models."]
            else if !models_loading then
              small ~a:[a_class ["text-muted"]] [txt "Loading models..."]
            else if !models_error <> "" then
              div
                [ small ~a:[a_class ["text-danger"]] [txt !models_error]
                ; button
                    ~a:
                      [ a_button_type `Button
                      ; a_class ["btn"; "btn-outline-secondary"; "btn-sm"]
                      ; a_onclick (fun _ ->
                            loaded_for := None ;
                            Helpers.trigger_render () ;
                            false ) ]
                    [txt "Retry"] ]
            else small [] ) ]
    ; div
        ~a:[a_class ["mb-3"]]
        [ button
            ~a:
              ( [ a_button_type `Button
                ; a_class ["btn"; "btn-outline-primary"]
                ; a_onclick (fun _ -> test_llm () ; false) ]
              @
              if !test_loading || not (List.mem !model !models) then
                [a_disabled ()]
              else [] )
            [txt (if !test_loading then "Testing..." else "Test LLM")]
        ; small
            ~a:[a_class ["d-block"; "text-muted"; "mt-1"]]
            [ txt
                "Sends a short prompt to the selected model; no submission \
                 data is included." ]
        ; ( match !test_result with
          | None -> div []
          | Some (success, message) ->
              p
                ~a:
                  [ a_class
                      [ "mt-2"
                      ; (if success then "text-success" else "text-danger") ]
                  ; a_aria "live" ["polite"] ]
                [txt message] ) ]
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
