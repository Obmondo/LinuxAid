# @summary
#   Manage an HAProxy map file as documented in
#   https://cbonte.github.io/haproxy-dconv/configuration-1.5.html#7.3.1-map
#
# @note
#   A map file contains one key + value per line. These key-value pairs are
#   specified in the `mappings` array or by additional `haproxy::mapfile::entry`
#   definitions.
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
# @param ensure
#   The state of the underlying file resource, either 'present' or 'absent'.
#   Default: 'present'
#
# @param owner
#   The owner of the underlying file resource. Defaut: 'root'
#
# @param group
#   The group of the underlying file resource. Defaut: 'root'
#
# @param mode
#   The mode of the underlying file resource. Defaut: '0644'
#
# @param instances
#   Array of managed HAproxy instance names to notify (restart/reload) when the
#   map file is updated. This is so that the same map file can be used with
#   multiple HAproxy instances. Default: `[ 'haproxy' ]`
#
define haproxy::mapfile (
  Array[Variant[String, Hash]]  $mappings   = [],
  Enum['present', 'absent']     $ensure     = 'present',
  String                        $owner      = 'root',
  String                        $group      = 'root',
  String                        $mode       = '0644',
  Array                         $instances  = ['haproxy'],
) {
  $mapfile_name = $title

  $_instances = flatten($instances)

  $_mapfile_name = "${haproxy::config_dir}/${mapfile_name}.map"

  concat { "haproxy_mapfile_${mapfile_name}":
    ensure => $ensure,
    owner  => $owner,
    group  => $group,
    mode   => $mode,
    path   => $_mapfile_name,
    notify => Haproxy::Service[$_instances],
  }

  $parameters = {
    'mappings'     => $mappings,
    'mapfile_name' => $mapfile_name,
  }

  concat::fragment { "haproxy_mapfile_${mapfile_name}-top":
    target  => $_mapfile_name,
    content => epp('haproxy/haproxy_mapfile.epp', $parameters),
    order   => '00',
  }
}
