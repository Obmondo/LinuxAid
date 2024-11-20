# Prometheus cAdvisor exporter
class common::monitor::exporter::cadvisor (
  Boolean             $enable      = $common::monitor::exporter::enable,
  Boolean[false]      $noop_value  = false,
  Stdlib::Port        $listen_port = 63392,
  Eit_types::Certname $host        = $trusted['certname'],
) {

  File {
    noop => $noop_value
  }

  @@prometheus::scrape_job { 'cadvisor' :
    job_name    => 'cadvisor',
    tag         => $::trusted['certname'],
    targets     => [ "${host}:${listen_port}" ],
    labels      => { 'certname' => $::trusted['certname'] },
    collect_dir => '/etc/prometheus/file_sd_config.d',
  }
}
