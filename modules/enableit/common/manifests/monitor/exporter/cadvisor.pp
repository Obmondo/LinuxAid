# @summary Class to manage the Prometheus cAdvisor exporter
#
# @param enable Whether to enable the exporter. Defaults to the value of $common::monitor::exporter::enable.
#
# @param noop_value The value to use for noop setting. Defaults to false.
#
# @param listen_port The port to listen on. Defaults to 63392.
#
# @param host The host certname. Defaults to $trusted['certname'].
#
class common::monitor::exporter::cadvisor (
  Boolean             $enable      = $common::monitor::exporter::enable,
  Boolean             $noop_value  = false,
  Stdlib::Port        $listen_port = 63392,
  Eit_types::Certname $host        = $trusted['certname'],
) {
  File {
    noop => $noop_value,
  }
  @@prometheus::scrape_job { 'cadvisor':
    job_name    => 'cadvisor',
    tag         => $::trusted['certname'],
    targets     => [ "${host}:${listen_port}" ],
    labels      => { 'certname' => $::trusted['certname'] },
    collect_dir => '/etc/prometheus/file_sd_config.d',
  }
}
