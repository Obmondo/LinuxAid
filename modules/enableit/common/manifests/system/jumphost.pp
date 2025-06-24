# class to setup reverse proxy
class common::system::jumphost (
  Eit_types::Common::System::Jumphosts $configs,
  Boolean                              $enable = false,
) {

  $configs.each |$_name, $options| {
    $exec_cmd = "ssh -NTC -o ServerAliveInterval=15 -o ExitOnForwardFailure=yes -R ${options['remote_port']}:localhost:22 ${options['username']}@${options['remote_host']}" #lint:ignore:140chars

    # Systemd Service
    systemd::manage_unit { "reverse-ssh-${_name}.service":
      enable        => $enable,
      active        => $enable,
      unit_entry    => {
        'Description'         => 'Reverse SSH Service',
        'ConditionPathExists' => '/usr/bin',
        'After'               => 'network.target',
      },
      service_entry => {
        'Type'       => 'simple',
        'User'       => $options['username'],
        'ExecStart'  => $exec_cmd,
        'RestartSec' => '3',
        'Restart'    => 'always',
      },
      install_entry => {
        'WantedBy' => 'multi-user.target',
      }
    }
  }
}
