# @summary Class for managing Prometheus Elasticsearch Exporter
#
# @param enable Boolean flag to enable or disable the exporter. Defaults to value of $common::monitor::exporter::enable.
#
# @param listen_address The IP and port for the exporter to listen on. Defaults to '127.254.254.254:9105'.
#
# @param noop_value Boolean for noop mode. Defaults to false.
#
# @groups settings enable, noop_value
#
# @groups network listen_address
#
class common::monitor::exporter::elasticsearch (
  Boolean               $enable         = $common::monitor::exporter::enable,
  Eit_types::IPPort     $listen_address = '127.254.254.254:9105',
  Eit_types::Noop_Value $noop_value     = $common::monitor::exporter::noop_value,
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
    noop        => $noop_value,
    subscribe   => File['/etc/systemd/system/elasticsearch_exporter.service'],
  } ~> Service['elasticsearch_exporter']
}
