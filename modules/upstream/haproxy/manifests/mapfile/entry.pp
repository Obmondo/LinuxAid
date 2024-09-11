# @summary
#   Manage an HAProxy map file as documented in
#   https://cbonte.github.io/haproxy-dconv/configuration-1.5.html#7.3.1-map
#
# @note
#   A map file contains one key + value per line. These key-value pairs are
#   specified in the `mappings` array.
#
#
# @param name
#   The namevar of the defined resource type is the filename of the map file
#   (without any extension), relative to the `haproxy::config_dir` directory.
#   A '.map' extension will be added automatically.
#
# @param mappings
#   An array of mappings for this map file. Array elements may be Hashes with a
#   single key-value pair each (preferably) or simple Strings. Default: `[]`
#
# @param mapfile
#   A string that specifies the name of the mapfile. Default value: ''.
#
# @param order
#   Defines the order for the mapfile. Accepts Integer or Strings. Default value: '10'.
#
define haproxy::mapfile::entry (
  String                       $mapfile,
  Array[Variant[String, Hash]] $mappings = [$title],
  Variant[String, Integer]     $order = '10',
) {
  $_mapfile_name = "${haproxy::config_dir}/${mapfile}.map"

  $parameters = {
    'mappings'     => $mappings,
    'mapfile_name' => $title,
  }

  concat::fragment { "haproxy_mapfile_${mapfile}-${title}":
    target  => $_mapfile_name,
    content => epp('haproxy/haproxy_mapfile.epp', $parameters),
    order   => $order,
  }
}
