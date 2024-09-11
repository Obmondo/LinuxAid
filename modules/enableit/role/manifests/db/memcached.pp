# Memcached role
class role::db::memcached (
  Boolean $ensure = true,
) inherits ::role::db {

  class { '::profile::memcached':
    memcached => $ensure,
  }
}
