type t = {
    type_lookup: Type_lookup.conn option;
    definition_blacklist: Index_blacklist.t option;
    repository_root_url: string option;
    directory_mappings: Directory_mappings.t;
    usedby_table: UsedByTable.t option;
    custom_css_file: string option;
    xref_modules: (string, unit) Hashtbl.t;
    xref_table: XrefTable.t;
  }
let default = {
    type_lookup = None;
    definition_blacklist = None;
    repository_root_url = None;
    directory_mappings = Directory_mappings.empty;
    usedby_table = None;
    custom_css_file = None;
    xref_modules = Hashtbl.create 100;
    xref_table = XrefTable.empty;
}
