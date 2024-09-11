# Installs and sets up tcp shaker in daemon mode on that system
class common::network::tcpshaker (
  Stdlib::Port      $listen_port,
  Integer           $check_interval,
  Integer           $requests_per_check,
  Integer           $concurrency,
  Boolean           $enable        = false,
  Array[String]     $tcp_addresses = [],
  Optional[Boolean] $noop_value    = undef
) {


  $config_location = '/etc/tcpshaker.yaml'
  $package_name = 'tcp-shaker'

  file { $config_location:
    ensure  => ensure_file($enable),
    noop    => $noop_value,
    content => epp('common/network/tcpshaker.yaml.epp', {
      listen_port    => $listen_port,
      tcp_addresses  => $tcp_addresses,
      check_interval => $check_interval,
    }),
  }

  package { $package_name:
    ensure => ensure_latest($enable),
    noop   => $noop_value,
  }

  common::services::systemd { 'tcpshaker.service':
    ensure     => $enable,
    enable     => $enable,
    noop_value => $noop_value,
    unit       => {
      'Description' => 'TCP Shaker Daemon Mode',
    },
    service    => {
      'Type'      => 'simple',
      'ExecStart' => "/opt/obmondo/bin/tcp_shaker -d -f ${config_location} -n ${requests_per_check} -c ${concurrency}",
    },
    require    => [
      Package[$package_name],
      File[$config_location],
    ],
  }

  include common::monitor::exporter::tcpshaker

}
