# @summary Cassandra role.
#
# @param settings A hash of Cassandra configuration options.
#
# @groups configurations settings.
#
class role::db::cassandra (
  Hash $settings = {},
) inherits ::role::db {
  contain profile::db::cassandra
  contain common::backup::cassandra
}
