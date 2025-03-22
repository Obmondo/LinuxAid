
# @summary Class for managing the Redis database
#
# @param bind The IP address and port to bind to. Defaults to ['0.0.0.0'].
#
# @param default_port The default port for Redis. Defaults to 6379.
#
class role::db::redis (
  Array[Variant[Eit_types::IPPort, Eit_types::IP], 1] $bind            = ['0.0.0.0'],
  Stdlib::Port $default_port                                         = 6379,
) inherits ::role::db {

  class { 'profile::redis':
    bind         => $bind,
    default_port => $default_port,
  }
}
