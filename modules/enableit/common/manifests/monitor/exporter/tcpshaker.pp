# Prometheus tcpshaker daemon mode / exporter
class common::monitor::exporter::tcpshaker (
  Boolean              $enable      = $common::network::tcpshaker::enable,
  Stdlib::Port         $listen_port = pick($common::network::tcpshaker::listen_port, 8785),
  Eit_types::Certname  $host        = $trusted['certname'],
  Boolean[false]       $noop_value  = false,

) {

  File {
    noop => $noop_value
  }

  prometheus::scrape_job { 'tcpshaker' :
    job_name    => 'tcpshaker',
    tag         => $::trusted['certname'],
    targets     => [ "${host}:${listen_port}" ],
    labels      => { 'certname' => $trusted['certname'] },
    collect_dir => '/etc/prometheus/file_sd_config.d',
  }
}
