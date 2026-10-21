open Common

type t = string
type dot = t

let from_file filename = filename

let generate_file pngfile mapfile srcfile =
  Common.shell (Printf.sprintf "tred %s | dot -Tpng -o %s -Tcmapx -o %s" srcfile pngfile mapfile)

let generate_svg ?style outputfile srcfile =
  let style = Option.value ~default:"" style in
  Common.shell (!%"tred %s | dot %s -Tsvg -o %s" srcfile style outputfile)

let of_string body =
  let filename = "__tmp__.dot" in
  file_using_w filename (fun ch -> output_string ch body);
  filename
