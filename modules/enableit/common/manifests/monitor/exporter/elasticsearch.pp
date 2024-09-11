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
  }

  # The upstream module does not have support for removing the unit file 
  # will rase the PR for that later will remove from this resources file
  if !$enable {
    File { '/etc/systemd/system/elasticsearch_exporter.service':
      ensure => absent,
    }
  }
}
