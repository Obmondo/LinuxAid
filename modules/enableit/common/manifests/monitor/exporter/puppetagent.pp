# Prometheus puppet-agent Exporter
class common::monitor::exporter::puppetagent (
  Boolean                      $enable           = $common::monitor::exporter::enable,
  Boolean[false]               $noop_value       = false,
  Eit_types::IPPort            $listen_address   = '127.254.254.254:63384',
  Eit_types::Duration::Seconds $interval_seconds = 120,
) {

  File {
    noop => $noop_value
  }

  Service {
    noop => $noop_value
  }

  Package {
    noop => $noop_value
  }

  User {
    noop => $noop_value
  }

  Group {
    noop => $noop_value
  }

  prometheus::daemon { 'puppet-agent-exporter':
    package_name      => 'obmondo-puppetagent-exporter',
    version           => '0.2.0',
    service_enable    => $enable,
    service_ensure    => ensure_service($enable),
    manage_user       => false,
    manage_group      => false,
    package_ensure    => ensure_latest($enable),
    init_style        => if !$enable { 'none' },
    install_method    => 'package',
    tag               => $::trusted['certname'],
    user              => 'root',
    group             => 'root',
    notify_service    => Service['puppet-agent-exporter'],
    real_download_url => 'https://github.com/retailnext/puppet-agent-exporter',
    export_scrape_job => $enable,
    options           => "--web.listen-address=${listen_address}",
    scrape_port       => Integer($listen_address.split(':')[1]),
    scrape_host       => $trusted['certname'],
    scrape_job_name   => 'puppetagent',
  }

}
