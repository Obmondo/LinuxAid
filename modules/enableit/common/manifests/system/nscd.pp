# @summary Class for managing NSCD setup, caching DNS daemon, locally on client
#
# @param manage Boolean flag to manage the nscd service. Defaults to true.
#
# @param ensure Desired ensure state for nscd. Defaults to true.
#
# @param debug_level Integer from 0 to 5 indicating debug level. Defaults to 0.
#
# @param cache_passwd Boolean to cache passwd entries. Defaults to false.
#
# @param cache_group Boolean to cache group entries. Defaults to false.
#
# @param cache_netgroup Boolean to cache netgroup entries. Defaults to false.
#
# @param cache_services Boolean to cache services. Defaults to false.
#
# @param use_socket_activation Boolean to enable socket activation. Defaults to false.
#
# @groups management manage, ensure.
#
# @groups caching cache_passwd, cache_group, cache_netgroup, cache_services.
#
# @groups configuration debug_level, use_socket_activation.
#
class common::system::nscd (
  Boolean      $manage                = true,
  Boolean      $ensure                = true,
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
