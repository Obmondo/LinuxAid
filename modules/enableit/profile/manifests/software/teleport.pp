# teleport
class profile::software::teleport (
  Boolean               $enable     = $common::software::teleport::enable,
  Eit_types::Noop_Value $noop_value = $common::software::teleport::noop_value,
  Optional[String]      $join_token = $common::software::teleport::join_token,
  Optional[String]      $ca_pin     = $common::software::teleport::ca_pin,
)
{
  package { 'teleport':
    ensure => ensure_latest($enable),
    noop   => $noop_value,
  }

  service { 'teleport':
    ensure    => ensure_service($enable),
    noop      => $noop_value,
    require   => [
      Package['teleport'],
      File['/etc/teleport.yaml'],
    ],
    subscribe => Package['ca-certificates'],
  }

  # Define the override content
  $_teleport_override = @("EOT"/)
    [Service]
    RuntimeDirectory=teleport
    | EOT

  # Create the drop-in override file
  systemd::unit_file { 'teleport.service':
    ensure  => ensure_present($enable),
    path    => '/etc/systemd/system/teleport.service.d',
    content => $_teleport_override,
    notify  => Service['teleport'],
  }

  file { '/etc/teleport.yaml':
    ensure  => ensure_present($enable),
    noop    => $noop_value,
    content => stdlib::to_yaml({
      'teleport'        => {
        'nodename'     => $facts['networking']['hostname'],
        'data_dir'     => '/run/teleport',
        'auth_token'   => $join_token,
        'auth_servers' => [
          'teleport.obmondo.com:443'
        ],
        'log'          => {
          'output'   => stderr,
          'severity' => 'INFO',
        },
        'ca_pin'       => $ca_pin,
        },
        'auth_service'  => {
          'enabled' => false,
        },
        'ssh_service'   => {
          'enabled' => true,
          'labels'  => {
            'environment' => 'GN',
          },
        },
        'proxy_service' => {
          'enabled' => false,
        }
    }),
    notify  => Service['teleport'],
  }
}
