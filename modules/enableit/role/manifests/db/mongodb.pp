
# @summary Class for managing the MongoDB role
#
class role::db::mongodb inherits ::role::db {

  # FUTURE: When we support replication from the role, make sure to default to
  # the v1 protocol: https://jepsen.io/analyses/mongodb-3-4-0-rc3
  contain profile::db::mongodb
}
