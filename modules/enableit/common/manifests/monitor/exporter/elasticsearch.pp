# Prometheus elasticsearch Exporter
class common::monitor::exporter::elasticsearch (
  Boolean           $enable         = $common::monitor::exporter::enable,
  Eit_types::IPPort $listen_address = '127.254.254.254:9105',
) {

  class { 'prometheus::elasticsearch_exporter':
    package_name      => 'obmondo-elasticsearch-exporter',
    service_name      => 'elasticsearch_exporter',
    package_ensure    => ensure_latest($enable),
    service_enable    => $enable,
    manage_service    => $enable,
    service_ensure    => ensure_service($enable),
    init_style        => if !$enable { 'none' },
    restart_on_change => $enable,
    user              => 'elasticsearch_exporter',
    group             => 'elasticsearch_exporter',
    export_scrape_job => $enable,
    tag               => $::trusted['certname'],
    extra_options     => "--web.listen-address=${listen_address}",
    scrape_port       => Integer($listen_address.split(':')[1]),
    scrape_host       => $::trusted['certname'],
    scrape_job_labels => { 'certname' => $::trusted['certname'] },
  }

  # NOTE: This is a daemon-reload, which will do a daemon-reload in noop mode.
  # upstream module cant handle noop. (which is correct)
  Exec <| tag == 'systemd-elasticsearch_exporter.service-systemctl-daemon-reload' |> {
    noop => $noop_value,
  }
}
