type status = Queued | Running | Succeeded | Failed

let states : (string, status) Hashtbl.t = Hashtbl.create 32

let pending : (string * (unit -> unit Lwt.t)) Queue.t = Queue.create ()

let listeners : (int * (string -> status -> unit)) list ref = ref []

let next_listener = ref 0

let active = ref false

let status key = Hashtbl.find_opt states key

let subscribe listener =
  let id = !next_listener in
  incr next_listener ;
  listeners := (id, listener) :: !listeners ;
  fun () -> listeners := List.filter (fun (n, _) -> n <> id) !listeners

let set_status key state =
  Hashtbl.replace states key state ;
  List.iter
    (fun (_, listener) -> try listener key state with _ -> ())
    !listeners

let rec run_next () =
  if (not !active) && not (Queue.is_empty pending) then (
    let key, run = Queue.take pending in
    active := true ;
    set_status key Running ;
    Lwt.async (fun () ->
        Lwt.finalize run (fun () ->
            active := false ;
            run_next () ;
            Lwt.return_unit ) ) )

let enqueue ~key ~run ~on_result =
  match status key with
  | Some (Queued | Running) -> false
  | None | Some (Succeeded | Failed) ->
      set_status key Queued ;
      Queue.add
        ( key
        , fun () ->
            Lwt.try_bind run
              (fun value ->
                set_status key Succeeded ;
                on_result (Ok value) ;
                Lwt.return_unit )
              (fun error ->
                set_status key Failed ;
                on_result (Error error) ;
                Lwt.return_unit ) )
        pending ;
      run_next () ;
      true
