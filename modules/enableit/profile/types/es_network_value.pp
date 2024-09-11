# Either a single value or an array of values
type Profile::Es_network_value = Variant[
  Eit_types::Hostname,
  Eit_types::IP,
  Enum['_local_', '_site_', '_global_'], # es special values
  Pattern[/[a-zA-Z0-9]+/],               # match network interface names
  Array[Variant[
    Eit_types::Hostname,
    Eit_types::IP,
    Enum['_local_', '_site_', '_global_'], # es special values
    Pattern[/[a-zA-Z0-9]+/]                # match network interface names
  ]]
]
