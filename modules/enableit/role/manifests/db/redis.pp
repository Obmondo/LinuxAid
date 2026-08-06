
# @summary Class for managing the Redis database
#
class role::db::redis inherits ::role::db {

  class { 'profile::db::redis':
    bind         => ['0.0.0.0'],
    default_port => 6379,
  }
}
