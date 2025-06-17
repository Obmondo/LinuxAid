# class to setup reverse proxy
class common::setup::jumphost (
  String           $ensure       = 'running',
  Optional[Hash[String, Eit_types::Common::Setup::Jumphost]] $config = undef,
) {
  if $config != undef {
    $config.each |String $name, Eit_types::Common::Setup::Jumphost $service_config| {
      if $service_config['username'] == '' or $service_config['remote_host'] == '' {
        fail("username and remote host cannot be empty")
      }
      $port = $service_config['port'] ? {
        undef   => 22,
        default => $service_config['port'],
      }
      $host = $service_config['host'] ? {
        undef   => 'localhost',
        ''      => 'localhost',
        default => $service_config['host'],
      }
      $exec_cmd = "ssh -NTC -o ServerAliveInterval=15 -o ExitOnForwardFailure=yes -R ${service_config['remote_port']}:${host}:${port} ${service_config['username']}@${service_config['remote_host']}"
      common::services::systemd { $name:
        ensure  => $ensure,
        unit    => {
          'Description'          => 'Reverse SSH Service',
          'ConditionPathExists'  => '/usr/bin',
          'After'                => 'network.target',
        },
        service => {
          'Type'        => 'simple',
          'User'        => $service_config['username'],
          'ExecStart'   => $exec_cmd,
          'RestartSec'  => '3',
          'Restart'     => 'always',
        },
        install => {
          'WantedBy' => 'multi-user.target',
        },
      }
    }
  }
}
