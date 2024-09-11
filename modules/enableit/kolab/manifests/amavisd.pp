# Manage amavisd
class kolab::amavisd {
  # amavisd needs to have $myhostname set to fqdn
  file_line { 'amavisd_conf_hostname':
    ensure => 'present',
    path   => '/etc/amavisd/amavisd.conf',
    line   => "\$myhostname = '${::fqdn}';"
  }

  file { '/var/run/amavisd' :
    ensure => directory,
    mode   => '0755',
    owner  => 'amavis',
    group  => 'amavis'
  }

  service { 'amavisd' :
    ensure  => running,
    enable  => true,
    require => [ Package['amavisd-new'], File['/var/run/amavisd'] ]
  }
}
