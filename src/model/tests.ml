open Js_of_ocaml

(* --- Types --- *)

type input_kind = [`Text | `Json]

type test = {id: int; mutable input: string; mutable kind: input_kind}

let tests = ref []

let counter = ref 0

(* --- Conversion helpers --- *)

let string_of_kind = function `Text -> "Text" | `Json -> "Json"

let input_kind_of_string = function
  | "Text" -> `Text
  | "Json" -> `Json
  | _ -> `Json

let test_to_obj t =
  object%js
    val id = t.id

    val input = t.input

    val kind = string_of_kind t.kind
  end

(*let test_of_obj (o : < id: int ; input: string ; kind: string ; .. > Js.t)
  = {id= o##.id; input= o##.input; kind= input_kind_of_string o##.kind}*)

(* --- localStorage persistence --- *)

let save_tests () =
  let arr = Js.array (Array.of_list (List.map test_to_obj !tests)) in
  let json = Js._JSON##stringify arr in
  Helpers.set_local_variable "tests" (Js.to_string json) ;
  Helpers.set_local_variable "tests-count" (string_of_int !counter)

let load_tests () =
  (tests :=
     match Helpers.get_local_variable "tests" with
     | None -> []
     | Some json_str ->
         let parsed = Js._JSON##parse json_str in
         let arr : < > Js.t Js.js_array Js.t = Js.Unsafe.coerce parsed in
         Array.to_list (Js.to_array arr)
         |> List.map (fun o ->
             let o = Js.Unsafe.coerce o in
             { id= o##.id
             ; input= o##.input
             ; kind= input_kind_of_string (Js.to_string o##.kind) } ) ) ;
  counter :=
    match Helpers.get_local_variable "tests-count" with
    | None -> 0
    | Some count -> int_of_string (Js.to_string count)

(* --- Modify tests --- *)

let add_test ?(input = "") ?(kind = `Text) () =
  incr counter ;
  let test = {id= !counter; input; kind} in
  tests := test :: !tests ;
  save_tests () ;
  test

let remove_test id =
  tests := List.filter (fun t -> t.id <> id) !tests ;
  save_tests ()

let export () =
  let json =
    `List
      (List.map
         (fun t ->
           `Assoc
             [ ("id", `Int t.id)
             ; ("input", `String t.input)
             ; ("type", `String (string_of_kind t.kind)) ] )
         !tests )
  in
  Console.console##log (Js.string (Yojson.Basic.to_string json))
