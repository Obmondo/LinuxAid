# @summary Class for managing the Prometheus tcpshaker daemon mode / exporter
#
# @param noop_value The noop flag for Puppet resources. Defaults to false.
#
# @groups settings noop_value
#
class common::monitor::exporter::tcpshaker (
  Eit_types::Noop_Value $noop_value = $common::monitor::exporter::noop_value,
) {
  $listen_port = pick($common::network::tcpshaker::listen_port, 8785)

  File {
    noop => $noop_value
  }

  prometheus::scrape_job { 'tcpshaker':
    job_name    => 'tcpshaker',
    tag         => $::trusted['certname'],
    targets     => [ "${trusted['certname']}:${listen_port}" ],
    labels      => { 'certname' => $trusted['certname'] },
    collect_dir => '/etc/prometheus/file_sd_config.d',
  }
}
