# NSCD setup, caching dns daemon, locally on client
class common::system::nscd (
  Boolean      $manage                = true,
  Boolean      $ensure                = true,
  # FIXME: what's the range?
  Integer[0,5] $debug_level           = 0,
  Boolean      $cache_passwd          = false,
  Boolean      $cache_group           = false,
  Boolean      $cache_netgroup        = false,
  Boolean      $cache_services        = false,
  Boolean      $use_socket_activation = false,
) {

  if $manage {
    contain profile::system::nscd
  }
}
