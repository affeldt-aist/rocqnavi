val filename : string

type scope

val notation_of_item : string * string * string -> scope * string * string * string

val html_of_notation : scope * string * string * string -> string

val generate_body : string -> (string * string * string) list -> string
