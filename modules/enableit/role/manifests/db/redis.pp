# Redis role
class role::db::redis (
  Array[Variant[Eit_types::IPPort, Eit_types::IP], 1] $bind = ['0.0.0.0'],
  Stdlib::Port $default_port                                = 6379,
) inherits ::role::db {

  class { 'profile::redis':
    bind         => $bind,
    default_port => $default_port,
  }
}
