# NIS/yp
class profile::system::authentication::nis (
  Boolean                                        $enable  = $common::user_management::authentication::nis::enable,
  Variant[Eit_types::SimpleString, Stdlib::Host] $domain  = $common::user_management::authentication::nis::domain,
  Array[Stdlib::IP::Address]                     $servers = $common::user_management::authentication::nis::servers,
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
