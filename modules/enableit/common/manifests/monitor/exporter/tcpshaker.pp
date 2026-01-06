# @summary Class for managing the Prometheus tcpshaker daemon mode / exporter
#
# @param enable Enable or disable the exporter. Defaults to the value of $common::network::tcpshaker::enable.
#
# @param listen_port The port to listen on. Defaults to $common::network::tcpshaker::listen_port or 8785 if undefined.
#
# @param host The host certificate name. Defaults to $trusted['certname'].
#
# @param noop_value The noop flag for Puppet resources. Defaults to false.
#
# @groups general enable, noop_value
#
# @groups network listen_port, host
#
class common::monitor::exporter::tcpshaker (
  Boolean               $enable      = $common::network::tcpshaker::enable,
  Stdlib::Port          $listen_port = pick($common::network::tcpshaker::listen_port, 8785),
  Eit_types::Certname   $host        = $trusted['certname'],
  Eit_types::Noop_Value $noop_value  = $common::monitor::exporter::noop_value,
) {

  File {
    noop => $noop_value
  }

  prometheus::scrape_job { 'tcpshaker':
    job_name    => 'tcpshaker',
    tag         => $::trusted['certname'],
    targets     => [ "${host}:${listen_port}" ],
    labels      => { 'certname' => $trusted['certname'] },
    collect_dir => '/etc/prometheus/file_sd_config.d',
  }
}
