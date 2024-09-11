# Prometheus Dns Exporter
class common::monitor::exporter::dns (
  Boolean                      $enable           = $common::monitor::exporter::enable,
  Boolean[false]               $noop_value       = false,
  Eit_types::IPPort            $listen_address   = '127.254.254.254:63395',
  Eit_types::Duration::Seconds $interval_seconds = 120,
  Array[Eit_types::Hostname]   $domains          = [
    'nrk.no',
    'vg.no',
    'example.com',
  ],
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

  $_domains = $domains
  $_options = [
    "-listen-address=${listen_address}",
    "-test-hosts ${_domains.join(',')}",
    "-test-interval-seconds ${interval_seconds}",
  ]

  prometheus::daemon { 'dns_exporter':
    package_name      => 'obmondo-dns-exporter',
    version           => '1.0.13',
    service_enable    => $enable,
    service_ensure    => ensure_service($enable),
    package_ensure    => ensure_latest($enable),
    init_style        => if !$enable { 'none' },
    install_method    => 'package',
    tag               => $::trusted['certname'],
    user              => 'dns_exporter',
    group             => 'dns_exporter',
    notify_service    => Service['dns_exporter'],
    real_download_url => 'https://github.com/anton-yurchenko/dns-exporter',
    export_scrape_job => $enable,
    options           => $_options.join(' '),
    scrape_port       => Integer($listen_address.split(':')[1]),
    scrape_host       => $trusted['certname'],
    scrape_job_name   => 'dns',
  }

  # The upstream module does not have support for removing the unit file 
  # will rase the PR for that later will remove from this resources file
  if !$enable {
    File { '/etc/systemd/system/dns_exporter.service':
      ensure => absent,
    }
  }
}
