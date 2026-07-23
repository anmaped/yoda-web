type language = EN | FR | ES | PT | AR

val current_language : unit -> language
val set_language : language -> unit
val t : string -> string
val languages : (language * string) list  (* (code, native_name) *)
val init : unit -> unit
