# Redis Profile
class profile::redis (
  Array[Variant[Eit_types::IPPort, Eit_types::IP], 1] $bind = ['127.0.0.1'],
  Stdlib::Absolutepath $datadir                             = '/var/lib/redis',
) {

  # Monitoring
  contain common::monitor::redis

  # Class
  class { 'eit_redis':
    bind    => $bind,
    dir     => $datadir,
    daemon  => false,
    logfile => undef,
  }
}
