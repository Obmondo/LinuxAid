# @summary Class for managing the Prometheus Blackbox Exporter
#
# @param enable Boolean to enable or disable the exporter. Defaults to false.
#
# @param noop_value Boolean to set noop for resources. Defaults to false.
#
class common::monitor::exporter::pushprox (
  Boolean $enable     = false,
  Boolean $noop_value = false,
) {
  file { '/etc/default/pushprox-client':
    ensure => absent,
    noop   => $noop_value,
  }
  package { 'obmondo-pushprox-client':
    ensure => absent,
    noop   => $noop_value,
  }
  user { 'pushprox-client':
    ensure => absent,
    noop   => $noop_value,
  }
  group { 'pushprox-client':
    ensure => absent,
    noop   => $noop_value,
  }
  service { 'pushprox-client':
    ensure   => stopped,
    noop     => $noop_value,
    notify   => [
      User['pushprox-client'],
      Group['pushprox-client'],
      Package['obmondo-pushprox-client'],
    ],
  }
}
