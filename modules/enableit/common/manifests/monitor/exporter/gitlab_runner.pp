# @summary Class for managing the Prometheus GitLab Runner exporter
#
# @param noop_value The value for noop. Defaults to false.
#
# @groups settings noop_value
#
class common::monitor::exporter::gitlab_runner (
  Eit_types::Noop_Value $noop_value = $common::monitor::exporter::noop_value,
) {
  File {
    noop => $noop_value,
  }
  prometheus::scrape_job { 'gitlab_runner':
    job_name    => 'gitlab_runner',
    tag         => $::trusted['certname'],
    targets     => [ '127.254.254.254:63384' ],
    labels      => { 'certname' => $::trusted['certname'] },
    collect_dir => '/etc/prometheus/file_sd_config.d',
  }
}
