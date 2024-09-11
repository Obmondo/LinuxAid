# Rubrik backup
class profile::software::rubrik (
  Boolean           $enable     = $common::software::rubrik::enable,
  Optional[Boolean] $noop_value = $common::software::rubrik::noop_value,
){

  Package {
    noop => $noop_value,
  }

  Service {
    noop => $noop_value,
  }

  package { 'rubrik-agent':
    ensure => ensure_present($enable),
    noop   => $noop_value,
  }

  service { [
    'rubrikagents-backup.service',
    'rubrikagents-bootstrap.service',
  ]:
    ensure  => ensure_service($enable),
    enable  => $enable,
    require => Package['rubrik-agent'],
  }
}
