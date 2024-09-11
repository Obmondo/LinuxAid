# Azure dependency agent
class profile::software::dependencyagent (
  Boolean           $enable     = $common::software::dependencyagent::enable,
  Optional[Boolean] $noop_value = $common::software::dependencyagent::noop_value,
) {

  package { 'obmondo-mde-dependency-agent':
    ensure => ensure_present($enable),
    noop   => $noop_value
  }

  if $enable {
    exec { 'install dependency agent':
      command => 'yes | sh /usr/local/sbin/dependencyagentlinux',
      noop    => $noop_value,
      path    => '/sbin:/usr/sbin:/bin:/usr/bin',
      onlyif  => 'test ! -x /opt/microsoft/dependency-agent/bin/microsoft-dependency-agent',
      require => Package['obmondo-mde-dependency-agent'],
      before  => Service['microsoft-dependency-agent'],
    }
  }

  service { 'microsoft-dependency-agent':
    ensure => ensure_service($enable),
  }

  if !$enable {
    package { [
      'dependency-agent',
      'microsoft-dependency-agent-dkms',
    ]:
      ensure  => absent,
      require => Service['microsoft-dependency-agent'],
    }

  }
}
