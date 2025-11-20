# @summary Class for managing the Prometheus HAProxy exporter
#
# @param enable
# Boolean flag to enable the exporter. Defaults to the value of $common::monitor::exporter::enable.
#
# @param noop_value Boolean value for noop mode. Defaults to false.
#
# @param listen_port The port to listen on. Defaults to 63661.
#
# @param host The hostname or certname to use. Defaults to $trusted['certname'].
#
class common::monitor::exporter::haproxy (
  Boolean               $enable      = $common::monitor::exporter::enable,
  Eit_types::Noop_Value $noop_value  = $common::monitor::exporter::noop_value,
  Stdlib::Port          $listen_port = 63661,
  Eit_types::Certname   $host        = $trusted['certname'],
) {
  File {
    noop => $noop_value,
  }
  prometheus::scrape_job { 'haproxy':
    job_name    => 'haproxy',
    tag         => $::trusted['certname'],
    targets     => [ "${host}:${listen_port}" ],
    labels      => { 'certname' => $::trusted['certname'] },
    collect_dir => '/etc/prometheus/file_sd_config.d',
  }
}
