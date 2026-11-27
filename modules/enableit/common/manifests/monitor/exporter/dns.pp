# @summary Removes the DNS exporter (obmondo-dns-exporter) from hosts that still have it
#
# The DNS exporter has been dropped: its package source is gone from
# obmondo-custom-scripts and nothing consumes its metrics. This class only
# stops and purges the exporter on hosts that still run it, removes its user,
# group, unit and environment file, and exports the scrape job with
# ensure => absent so the Prometheus side drops it too.
#
# NOTE: delete this class and its include in common::monitor::exporter once
# every host has applied it (one release is enough).
#
# @param noop_value The value to use for noop mode. Defaults to the monitoring exporter noop value.
#
# @groups settings noop_value
#
class common::monitor::exporter::dns (
  Eit_types::Noop_Value $noop_value = $common::monitor::exporter::noop_value,
) {
  # Same port and scrape job name as the old daemon, so the exported scrape
  # job title matches the one still collected on the Prometheus side.
  $listen_address = '127.254.254.254:63395'

  File {
    noop => $noop_value,
  }
  Service {
    noop => $noop_value,
  }
  Package {
    noop => $noop_value,
  }
  User {
    noop => $noop_value,
  }
  Group {
    noop => $noop_value,
  }

  prometheus::daemon { 'dns_exporter':
    ensure            => 'absent',
    package_name      => 'obmondo-dns-exporter',
    version           => '1.0.13',
    service_enable    => false,
    service_ensure    => 'stopped',
    init_style        => $facts['service_provider'],
    install_method    => 'package',
    tag               => $::trusted['certname'],
    user              => 'dns_exporter',
    group             => 'dns_exporter',
    notify_service    => Service['dns_exporter'],
    real_download_url => 'https://github.com/anton-yurchenko/dns-exporter',
    export_scrape_job => true,
    scrape_port       => Integer($listen_address.split(':')[1]),
    scrape_host       => $trusted['certname'],
    scrape_job_name   => 'dns',
    scrape_job_labels => { 'certname' => $::trusted['certname'] },
  }

  # NOTE: the upstream module's daemon-reload cannot handle noop itself.
  Exec <| tag == 'systemd-dns_exporter.service-systemctl-daemon-reload' |> {
    noop => $noop_value,
  }
}
