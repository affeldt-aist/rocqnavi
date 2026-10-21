type elem

val text : string -> elem

val ul : elem list -> elem

val img : src:string -> ?alt:string -> unit -> elem

val a : href:string -> ?target:string -> elem list -> elem

val to_string : elem -> string

val details : ?id:string -> summary:elem list -> elem list -> elem

val hr : elem
