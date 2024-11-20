# Prometheus haproxy exporter
class common::monitor::exporter::haproxy (
  Boolean             $enable      = $common::monitor::exporter::enable,
  Boolean[false]      $noop_value  = false,
  Stdlib::Port        $listen_port = 63661,
  Eit_types::Certname $host        = $trusted['certname'],
) {

  File {
    noop => $noop_value
  }

  prometheus::scrape_job { 'haproxy' :
    job_name    => 'haproxy',
    tag         => $::trusted['certname'],
    targets     => [ "${host}:${listen_port}" ],
    labels      => { 'certname' => $::trusted['certname'] },
    collect_dir => '/etc/prometheus/file_sd_config.d',
  }
}
