# nscd
class profile::system::nscd (
  Boolean      $ensure                = $common::system::nscd::ensure,
  # FIXME: what's the range?
  Integer[0,5] $debug_level           = $common::system::nscd::debug_level,
  Boolean      $cache_passwd          = $common::system::nscd::cache_passwd,
  Boolean      $cache_group           = $common::system::nscd::cache_group,
  Boolean      $cache_netgroup        = $common::system::nscd::cache_netgroup,
  Boolean      $cache_services        = $common::system::nscd::cache_services,
  Boolean      $use_socket_activation = $common::system::nscd::use_socket_activation,
) inherits ::profile::system {

  package::install('nscd', {
    ensure => ensure_present($ensure),
  })

  file { '/etc/nscd.conf':
    ensure  => 'file',
    content => epp('profile/system/nscd.conf.epp', {
      debug_level    => $debug_level,
      cache_passwd   => $cache_passwd,
      cache_group    => $cache_group,
      cache_netgroup => $cache_netgroup,
      cache_services => $cache_services,
    }),
  }

  if $use_socket_activation {
    # When using systemd we can get away with just enabling the socket; systemd
    # will take care of the service
    service {
      default:
        require => Package['nscd'],
        ;

      'nscd.socket':
        ensure => $ensure,
        enable => $ensure,
        ;
    }

  } else {

    service { 'nscd':
      ensure  => $ensure,
      enable  => $ensure,
      require => Package['nscd'],
    }

  }
}
