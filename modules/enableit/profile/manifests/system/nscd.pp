# nscd
class profile::system::nscd () {

  package::install('nscd', {
    ensure => 'present',
  })

  file { '/etc/nscd.conf':
    ensure  => 'file',
    content => epp('profile/system/nscd.conf.epp', {
      debug_level    => 0,
      cache_passwd   => false,
      cache_group    => false,
      cache_netgroup => false,
      cache_services => false,
    }),
  }

  service { 'nscd':
    ensure  => true,
    enable  => true,
    require => Package['nscd'],
  }
}
