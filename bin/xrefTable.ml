module Key = struct
  type t = string * int
  let compare = compare
end

module Map = Map.Make (Key)

let path sp id =
  match sp, id with
  | "<>", "<>" -> ""
  | "<>", _    -> id
  | _   , "<>" -> sp
  | _   , _    -> sp ^ "." ^ id

module Def = struct
  type t = {section:string; ident:string; kind: Glob_kind.t}
  let section def =
    if def.section = "<>" then None else Some def.section
  let kind def = def.kind
  let path def = path def.section def.ident

  let make section ident kind = {section; ident; kind}
end

type xref =
  | Defs of Def.t list
  | Ref of string * string * Glob_kind.t (* unit, path, type *)

let sxref = function
  | Defs defs -> "Defs[" ^ (List.map Def.path defs |> String.concat ", ")^"]"
  | Ref (unit, path, ty) ->
    Printf.sprintf "Ref(%s,%s,%s)" unit path (Glob_kind.to_string ty)

type t = (Range.t * xref) Map.t

let find map module_name pos =
  match Map.find_last_opt (fun key -> key <= (module_name, pos)) map with
  | None -> None
  | Some (_key, (range, xref)) ->
    if Range.in_ pos range then Some (range, xref)
    else None

let empty = Map.empty

let add_reference xref_table curmod pos_from pos_to dp sp id ty =
  if ty = Glob_kind.Other "sec" then xref_table else
  let range = (pos_from, pos_to) in
  match Map.find_opt (curmod, pos_from) xref_table with
  | Some (range0, xref) when range = range ->
     (* ignore references if the glob file has a reference and definitions at a
        same position.
        issue: https://github.com/yoshihiro503/coq2html/issues/2
      *)
    xref_table
  | _ ->
  Map.add (curmod, pos_from) (range, Ref (dp, path sp id, ty)) xref_table

let add_definition xref_table curmod pos_from pos_to sp id ty =
  if ty = Glob_kind.Other "sec" then xref_table else
  (*eprintf "add_definition %s %d %s %s %s\n" curmod pos_from sp id ty;*)
  let range = (pos_from, pos_to) in
  let def = Def.make sp id ty in
  match Map.find_opt (curmod, pos_from) xref_table with
  | None ->
     Map.add (curmod, pos_from) (range, Defs [def]) xref_table
  | Some (range0, Defs defs) ->
    if range <> range0 then
      Printf.eprintf "Warning: multiple paths share the same starting position: modules '%s' and ('%s') '%s' [%d:%d]\n" curmod sp id pos_from pos_to;
     Map.add (curmod, pos_from) (range, Defs (def :: defs)) xref_table
  | Some (_, Ref (unit, path_, typ)) ->
     (* ignore references if the glob file has a reference and definitions at a
        same position.
        issue: https://github.com/yoshihiro503/coq2html/issues/2
      *)
    Map.add  (curmod, pos_from) (range, Defs [def]) xref_table

let fold f xref_table init =
  Map.fold f xref_table init
