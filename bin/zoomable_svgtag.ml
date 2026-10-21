open Common

let get_viewbox svgstring =
  let re = Str.regexp {|viewBox="\([^"]+\)"|} in
  try
    ignore (Str.search_forward re svgstring 0);
    let s = Str.matched_group 1 svgstring in
    Scanf.sscanf s "%f %f %f %f"
      (fun x y width height ->  (x, y, width, height))
    |> Option.some
  with
  | Not_found -> None
  | Scanf.Scan_failure _ ->
     Log.warn (!%"scan error '%s'" svgstring); None

let is_small svgstring =
  match get_viewbox svgstring with
  | Some (_, _, width, _) when
    width < 800. -> true
  | _ -> false

let read_svg svg_path =
  let content =
    file_using_r svg_path (fun ch -> really_input_string ch (in_channel_length ch))
  in
  (* Strip the XML prolog and DOCTYPE that `dot -Tsvg` emits: they are only
     valid at the start of a standalone document and break the HTML parser
     when the <svg> element is inlined into an HTML page. *)
  let svg_start = Str.search_forward (Str.regexp_string "<svg") content 0 in
  String.sub content svg_start (String.length content - svg_start)

let div id svg_path =
  let svgstring = read_svg svg_path in
  let class_ = if is_small svgstring then "small-graph" else "graph" in
  !%{|<div id="%s" class="%s">%s</div>
<p class="svg-direct-link"><a href="%s" target="_blank">View raw SVG</a></p>|}
    id class_ svgstring (Filename.basename svg_path)
