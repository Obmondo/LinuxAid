# @summary Class for installing and setting up tcp shaker in daemon mode
#
# @param listen_port The port to listen on. Must be a Stdlib::Port.
#
# @param check_interval The interval between checks in seconds. Must be an Integer.
#
# @param requests_per_check Number of requests per check. Must be an Integer.
#
# @param concurrency Concurrency level. Must be an Integer.
#
# @param enable Whether to enable the service. Defaults to false.
#
# @param tcp_addresses Array of TCP addresses to bind to. Defaults to an empty array.
#
# @param noop_value Optional boolean to control noop behavior. Defaults to undef.
#
# @groups network listen_port, tcp_addresses.
#
# @groups operation check_interval, requests_per_check, concurrency.
#
# @groups service_control enable, noop_value.
#
class common::network::tcpshaker (
  Stdlib::Port      $listen_port,
  Integer           $check_interval,
  Integer           $requests_per_check,
  Integer           $concurrency,

  Boolean               $enable         = false,
  Array[String]         $tcp_addresses  = [],
  Eit_types::Noop_Value $noop_value     = undef,
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
