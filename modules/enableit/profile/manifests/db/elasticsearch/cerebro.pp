# Cerebro
class profile::db::elasticsearch::cerebro (
  Optional[String] $es_service_name = undef,
  Boolean $selinux = false,
) {

  package { 'cerebro':
    ensure => 'present',
  }

  service { 'cerebro':
    ensure  => 'running',
    require => Package['cerebro'],
  }

  file { '/etc/cerebro/application.conf':
    ensure  => 'present',
    content => epp('profile/db/elasticsearch/cerebro/application.conf.epp', {
      port   => 9000,
      secret => stdlib::fqdn_rand_string(64),
    }),
    before  => Service['cerebro'],
    notify  => Service['cerebro'],
  }
}
