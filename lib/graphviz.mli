type t
type dot = t

val from_file : string -> t

val generate_svg : ?style:string -> string -> t -> unit

val of_string : string -> t
