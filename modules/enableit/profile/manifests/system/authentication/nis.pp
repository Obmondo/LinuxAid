# NIS/yp
class profile::system::authentication::nis (
  Boolean                                        $enable  = $common::system::authentication::nis::enable,
  Variant[Eit_types::SimpleString, Stdlib::Host] $domain  = $common::system::authentication::nis::domain,
  Array[Stdlib::IP::Address]                     $servers = $common::system::authentication::nis::servers,
) {

  if $enable {
    package { 'ypbind':
      ensure => present,
    }

    file { '/etc/yp.conf':
      ensure  => present,
      content => epp('profile/authentication/nis/yp.conf.epp', {
        domain  => $domain,
        servers => $servers,
      }),
      require => Package['ypbind'],
      notify  => Service['ypbind'],
    }
  }

  $_service_before = if $enable {
    Class['nsswitch']
  }

  service { 'ypbind':
    ensure => $enable.ensure_service,
    enable => $enable,
    before => $_service_before,
  }

}
