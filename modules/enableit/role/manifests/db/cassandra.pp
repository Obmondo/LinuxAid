# @summary Cassandra role.
#
# @param settings A hash of Cassandra configuration options.
# @param cassandra_version The version of Cassandra to install (e.g., '41')
# @param seeds List of seed nodes for Cassandra
#
class role::db::cassandra (
  Hash                          $settings          = {},
  Enum[41]                      $cassandra_version = 41,
  Optional[Array[Stdlib::Host]] $seeds             = [],
) inherits ::role::db {

  contain profile::db::cassandra
}
