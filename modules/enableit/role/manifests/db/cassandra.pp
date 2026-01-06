# @summary Cassandra role.
#
# @param settings A hash of Cassandra configuration options.
#
# @param cassandra_version The version of Cassandra to install (e.g., '41')
#
# @param seeds List of seed nodes for Cassandra
#
# @param backup Indicates if backup should be enabled. Defaults to true.
#
# @groups configurations settings, cassandra_version.
#
# @groups networking seeds.
#
# @groups maintenance backup.
#
class role::db::cassandra (
  Hash                          $settings          = {},
  Enum['41']                    $cassandra_version = '41',
  Optional[Array[Stdlib::Host]] $seeds             = [],
  Boolean                       $backup            = true,
) inherits ::role::db {
  contain profile::db::cassandra

  if $backup {
    contain common::backup::cassandra
  }
}
