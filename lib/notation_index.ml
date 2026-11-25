open Common

let filename = "index_notations.html"

type scope = (* Notation Scope *)
| NoScope
| Scope of string

let show_scope = function
  | NoScope -> "no scope"
  | Scope scope -> scope

let compare_scope x y =
  match x, y with
  | NoScope, NoScope -> 0
  | NoScope, _ -> -1
  | _, NoScope -> 1
  | Scope x, Scope y -> compare x y

(**
*)
let notation_of_item (module_, linkname, item_name) =
  match Str.(bounded_split_delim (regexp ":") item_name 4) with
  | [_; _; ""; notation] -> (NoScope, notation, module_, linkname)
  | [_; _; scope; notation] -> (Scope scope, notation, module_, linkname)
  | _ ->
     failwith (!%"unexpected notation format in glob file: name=%s" item_name)

(**
*)
let html_of_notation (scope, notation, module_, linkname) =
  let scope =
    match scope with
    | NoScope -> {|<span class="warning">no scope</span>|}
    | Scope scope -> "in " ^ scope
  in
  let show notation =
    let len = String.length notation in
    let rec iter pos tags =
      let text_of_placeholder s =
        Str.(global_replace (regexp_string "_")  " " s)
      in
      if pos < len then
        match String.index_from_opt notation pos '\'' with
        | Some pos' when pos = pos' -> quoted (pos+1) tags []
        | Some pos' ->
           quoted (pos'+1)
             (text_of_placeholder (String.sub notation pos (pos'-pos)) :: tags) []
        | None ->
           List.rev (
               text_of_placeholder (String.sub notation pos (len - pos)) :: tags)
      else List.rev tags
    and quoted pos tags store =
      let tag_of_quoted ss =
        String.concat "" (List.rev ss)
        |> html_escaped
        |> !%"<span class=\"notation-symbol\">%s</span>"
      in
      if pos < len then
        match String.index_from_opt notation pos '\'' with
        | Some pos' when pos' = len - 1 ->
           tag_of_quoted (String.sub notation pos (pos'-pos) :: store) :: tags
           |> List.rev
        | Some pos' when String.get notation (pos'+1) = '\'' ->
           (* two contiguous quotations *)
           let s = String.sub notation pos (pos' - pos) in
           quoted (pos'+2) tags ("\'" :: s :: store)
        | Some pos' ->
           (* termination of the quote *)
           let tag = tag_of_quoted (String.sub notation pos (pos' - pos) :: store) in
           iter (pos' + 1) (tag :: tags)
        | None ->
           failwith "unclosed quote"
      else
        List.rev (tag_of_quoted store :: tags)
    in
    String.concat "" (iter 0 [])
  in
  let index_kind = "not" in
  !%{|<a href="%s">%s</a> [%s, in %s] (%s)|} linkname (show notation) index_kind module_ scope

let generate_body table items =
  let grouped =
    List.map notation_of_item items
    |> list_uniq
    |> Common.list_group_by (fun (scope, _, _, _) -> scope)
    |> List.sort (fun (s1, _) (s2, _) -> compare_scope s1 s2)
    |> List.map (fun (scope, nots) -> scope, Common.list_sort_by (fun (_, not, _, _) -> not) nots)
  in
  let html_of_group (scope, notations) =
    let h2 = !%"<h2>%s</h2>" (show_scope scope) in
    let tags = List.map html_of_notation notations in
    h2 ^ String.concat "<br>\n" tags
  in
  table ^ (String.concat "" @@ List.map html_of_group grouped)

