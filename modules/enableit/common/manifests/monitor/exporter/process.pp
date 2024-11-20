# Prometheus process Exporter
class common::monitor::exporter::process (
  Boolean           $enable         = true,
  Boolean[false]    $noop_value     = false,
  Eit_types::IPPort $listen_address = '127.254.254.254:63388',
) {

  class { 'prometheus::process_exporter':
    package_name      => 'obmondo-process-exporter',
    package_ensure    => ensure_latest($enable),
    service_enable    => $enable,
    service_ensure    => ensure_service($enable),
    manage_service    => $enable,
    init_style        => if !$enable { 'none' },
    restart_on_change => $enable,
    tag               => $::trusted['certname'],
    user              => process_exporter,
    group             => process_exporter,
    export_scrape_job => $enable,
    scrape_port       => Integer($listen_address.split(':')[1]),
    scrape_host       => $trusted['certname'],
    extra_options     => "--web.listen-address=${listen_address}",
    scrape_job_labels => { 'certname' => $::trusted['certname'] },
  }

  # NOTE: This is a daemon-reload, which will do a daemon-reload in noop mode.
  # upstream module cant handle noop. (which is correct)
  Exec <| tag == 'systemd-process_exporter.service-systemctl-daemon-reload' |> {
    noop => $noop_value,
  }
}
