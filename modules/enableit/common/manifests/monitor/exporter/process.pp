# Prometheus process Exporter
class common::monitor::exporter::process (
  Boolean           $enable         = true,
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
  }
  # The upstream module does not have support for removing the unit file 
  # will rase the PR for that later will remove from this resources file
  if !$enable {
    File { '/etc/systemd/system/process-exporter.service':
      ensure => absent,
    }
  }

}
