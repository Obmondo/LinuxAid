
# @summary Class for managing the Memcached role
#
# @param ensure Boolean value to ensure that memcached is present. Defaults to true.
#
# @groups ensure ensure
# 
class role::db::memcached (
  Boolean $ensure = true,
) inherits ::role::db {

  class { '::profile::memcached':
    memcached => $ensure,
  }
}
