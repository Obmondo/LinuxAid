# Ansoftrsmservice
class profile::software::ansoftrsmservice (
  Boolean $enable = true,
) {

if $enable {

  file { '/etc/init.d/ansoftrsmservice':
    ensure => 'present',
    source => 'puppet:///modules/profile/software/ansoftrsmservice',
  }

  common::services::systemd { 'ansoftrsmservice.service':
    ensure  => 'running',
    enable  => true,
    unit    => {
      'SourcePath'  => '/etc/init.d/ansoftrsmservice',
      'Description' => 'Ansoft Remote Simulation Manager init script (with modifications)',
      'After'       => 'network-online.target',
      'Wants'       => 'network-online.target',
      'Conflicts'   => 'shutdown.target',
    },
    service => {
      'Type'      => 'forking',
      'ExecStart' => '/tools/ansys/AnsysEM/rsm/Linux/ansoftrsmservice-wrapper start',
      'ExecStop'  => '/tools/ansys/AnsysEM/rsm/Linux/ansoftrsmservice-wrapper stop',

    },
    install => {
      'WantedBy' => 'multi-user.target',
    },
    require => File['/etc/init.d/ansoftrsmservice'],
  }

  service { 'ansoftrsmservice' :
    ensure  => 'running',
    require => File['/etc/init.d/ansoftrsmservice'],
  }
}}
