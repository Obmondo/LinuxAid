# Redhat insights-client
class profile::software::insights (
  Boolean           $enable     = $common::software::insights::enable,
  Optional[Boolean] $noop_value = $common::software::insights::noop_value,
){

  Package {
    noop => $noop_value,
  }

  Service {
    noop => $noop_value,
  }

  package { 'insights-client':
    ensure => ensure_present($enable),
    noop   => $noop_value,
  }

  service { [
    'insights-client',
    'insights-client.timer',
    'insights-client-results.path',
  ] :
    ensure  => ensure_service($enable),
    enable  => $enable,
    require => Package['insights-client'],
  }
}
