# @summary Class for managing the Prometheus GitLab Runner exporter
#
# @param enable Whether to enable the exporter. Defaults to $common::monitor::exporter::enable.
#
# @param noop_value The value for noop. Defaults to false.
#
# @param listen_address The IP and port to listen on. Defaults to '127.254.254.254:63384'.
#
# @param host The hostname. Defaults to $trusted['certname'].
#
class common::monitor::exporter::gitlab_runner (
  Boolean             $enable         = $common::monitor::exporter::enable,
  Boolean             $noop_value     = $common::monitor::exporter::noop_value,
  Eit_types::IPPort   $listen_address = '127.254.254.254:63384',
  Eit_types::Certname $host           = $trusted['certname'],
) {
  File {
    noop => $noop_value,
  }
  prometheus::scrape_job { 'gitlab_runner':
    job_name    => 'gitlab_runner',
    tag         => $::trusted['certname'],
    targets     => [ $listen_address ],
    labels      => { 'certname' => $::trusted['certname'] },
    collect_dir => '/etc/prometheus/file_sd_config.d',
  }
}
