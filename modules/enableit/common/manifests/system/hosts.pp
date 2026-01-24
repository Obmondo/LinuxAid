# @summary Class for managing host entries
#
# @param entries A hash of IP addresses mapped to host entries. Defaults to an empty hash.
#
# @groups entries entries
#
class common::hosts (
  Hash[
    Eit_types::IP,
    Variant[
      Struct[
        {
          ensure       => Optional[Boolean],
          host_aliases => Array,
        }
      ],
      Array,
    ]
  ] $entries = {},
) {
  $entries.each | $ip, $entry | {
    if type($entry) =~ Type[Hash] {
      # Get the first element
      $hosts = $entry['host_aliases'][0]

      # Skip the first element and get the rest of it
      $host_aliases = $entry['host_aliases'][1,-1]
    } else {
      # Get the first element
      $hosts = $entry[0]

      # Skip the first element and get the rest of it
      $host_aliases = $entry[1,-1]
    }

    host { $hosts:
      ensure       => 'present',
      ip           => $ip,
      host_aliases => $host_aliases,
      noop         => false,
    }
  }
}
