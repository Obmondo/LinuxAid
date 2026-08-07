# @summary Class for managing the Prometheus process exporter
#
# @param noop_value Whether to perform noop operations. Defaults to false.
#
# @groups settings noop_value
#
class common::monitor::exporter::process (
  Eit_types::Noop_Value $noop_value = $common::monitor::exporter::noop_value,
) {
  $listen_address = '127.254.254.254:63388'

  class { 'prometheus::process_exporter':
    package_name      => 'obmondo-process-exporter',
    package_ensure    => ensure_latest(true),
    service_enable    => true,
    service_ensure    => ensure_service(true),
    manage_service    => true,
    init_style        => $facts['service_provider'],
    restart_on_change => true,
    tag               => $::trusted['certname'],
    user              => process_exporter,
    group             => process_exporter,
    export_scrape_job => true,
    scrape_port       => Integer($listen_address.split(':')[1]),
    scrape_host       => $trusted['certname'],
    extra_options     => "--web.listen-address=${listen_address}",
    scrape_job_labels => { 'certname' => $::trusted['certname'] },
  }
  # NOTE: This is a daemon-reload, which will do a daemon-reload in noop mode.
  # upstream module cant handle noop. (which is correct)
  Exec <| tag == 'systemd-process-exporter.service-systemctl-daemon-reload' |> {
    noop        => $noop_value,
    subscribe   => File['/etc/systemd/system/process-exporter.service'],
  } ~> Service['process-exporter']
}
