# Prometheus gitlab_runner exporter
class common::monitor::exporter::gitlab_runner (
  Boolean             $enable         = $common::monitor::exporter::enable,
  Boolean[false]      $noop_value     = false,
  Eit_types::IPPort   $listen_address = '127.254.254.254:63384',
  Eit_types::Certname $host           = $trusted['certname'],
) {

  File {
    noop => $noop_value
  }

  prometheus::scrape_job { 'gitlab_runner' :
    job_name    => 'gitlab_runner',
    tag         => $::trusted['certname'],
    targets     => [ "${listen_address}" ],
    labels      => { 'certname' => $::trusted['certname'] },
    collect_dir => '/etc/prometheus/file_sd_config.d',
  }
}
