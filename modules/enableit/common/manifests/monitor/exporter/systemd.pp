# Prometheus Systemd Exporter
class common::monitor::exporter::systemd (
  Boolean            $enable         = $common::monitor::exporter::enable,
  Eit_types::IPPort  $listen_address = '127.254.254.254:63391',
) {

  class { 'prometheus::systemd_exporter':
    package_name      => 'obmondo-systemd-exporter',
    service_enable    => $enable,
    service_ensure    => ensure_service($enable),
    manage_service    => $enable,
    restart_on_change => $enable,
    user              => 'systemd_exporter',
    group             => 'systemd_exporter',
    init_style        => if !$enable { 'none' },
    export_scrape_job => $enable,
    extra_options     => "--web.listen-address=${listen_address} --web.max-requests=20",
    tag               => $::trusted['certname'],
    scrape_port       => Integer($listen_address.split(':')[1]),
    scrape_host       => $trusted['certname'],
  }

  # The upstream module does not have support for removing the unit file 
  # will rase the PR for that later will remove from this resources file
  if !$enable {
    File { '/etc/systemd/system/systemd_exporter.service':
      ensure => absent,
    }
  }
}
