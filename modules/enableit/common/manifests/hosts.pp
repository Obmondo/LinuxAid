# Host entry
# Eg No 1:
# common::hosts::entries:
#  '127.0.0.1':
#    host_aliases:
#      - 'cphapp.rema1000.dk'
#      - 'cphapplinuxprodtest.rema1000.dk'
#      - 'cphapplinuxtest.rema1000.dk'
#
# common::hosts::entries:
#  '127.0.0.1':
#    - 'cphapp.rema1000.dk'
#    - 'cphapplinuxprodtest.rema1000.dk'
#    - 'cphapplinuxtest.rema1000.dk'
class common::hosts (
  Hash[
    Eit_types::IP,
    Variant[
      Struct[{
        ensure       => Optional[Boolean],
        host_aliases => Array,
      }],
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
