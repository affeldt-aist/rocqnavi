type t = {
    type_lookup: Type_lookup.conn option;
    definition_blacklist: Index_blacklist.t option;
    repository_root_url: string option;
    directory_mappings: Directory_mappings.t;
    usedby_table: UsedByTable.t option;
    custom_css_file: string option;
  }

val default : t
