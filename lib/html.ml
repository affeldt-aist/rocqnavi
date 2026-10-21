type elem =
  | Tag of string * (string * string) list * elem list
  | Text of string

let void_elements = ["area"; "base"; "br"; "col"; "embed"; "hr"; "img"; "input"; "link"; "meta"; "param"; "source"; "track"; "wbr"]

let escape s =
  let b = Buffer.create (String.length s) in
  String.iter (fun c -> match c with
    | '&' -> Buffer.add_string b "&amp;"
    | '<' -> Buffer.add_string b "&lt;"
    | '>' -> Buffer.add_string b "&gt;"
    | '"' -> Buffer.add_string b "&quot;"
    | c -> Buffer.add_char b c) s;
  Buffer.contents b

let string_of_attrs attrs =
  String.concat "" (List.map (fun (k, v) -> Printf.sprintf " %s=\"%s\"" k (escape v)) attrs)

let rec to_string = function
  | Text s -> escape s
  | Tag (name, attrs, _) when List.mem name void_elements ->
    Printf.sprintf "<%s%s>" name (string_of_attrs attrs)
  | Tag (name, attrs, children) ->
    Printf.sprintf "<%s%s>%s</%s>" name (string_of_attrs attrs)
      (String.concat "" (List.map to_string children)) name

let text s = Text s

let li content = Tag ("li", [], [content])

let ul items = Tag ("ul", [], List.map li items)

let img ~src ?alt () =
  let attrs = ("src", src) :: (match alt with Some a -> [("alt", a)] | None -> []) in
  Tag ("img", attrs, [])

let a ~href ?target content =
  let attrs = ("href", href) :: (match target with Some t -> [("target", t)] | None -> []) in
  Tag ("a", attrs, content)

let details ?id ~summary content =
  let attrs = match id with Some id -> [("id", id)] | None -> [] in
  Tag ("details", attrs, Tag ("summary", [], summary) :: content)

let hr = Tag ("hr", [], [])
