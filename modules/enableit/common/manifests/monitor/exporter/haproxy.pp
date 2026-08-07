# @summary Class for managing the Prometheus HAProxy exporter
#
# @param enable Boolean flag to enable the exporter. Defaults to the value of $common::monitor::exporter::enable.
#
# @param noop_value Boolean value for noop mode. Defaults to the value of $common::monitor::exporter::noop_value.
#
# @groups settings enable, noop_value
#
class common::monitor::exporter::haproxy (
  Boolean               $enable     = $common::monitor::exporter::enable,
  Eit_types::Noop_Value $noop_value = $common::monitor::exporter::noop_value,
) {
  File {
    noop => $noop_value,
  }
  prometheus::scrape_job { 'haproxy':
    job_name    => 'haproxy',
    tag         => $::trusted['certname'],
    targets     => [ "${trusted['certname']}:63661" ],
    labels      => { 'certname' => $::trusted['certname'] },
    collect_dir => '/etc/prometheus/file_sd_config.d',
  }
}
