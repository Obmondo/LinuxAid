# Prometheus wireguard Exporter
class common::monitor::exporter::wireguard (
  Boolean           $enable         = $common::monitor::exporter::enable,
  Eit_types::IPPort $listen_address = '127.254.254.254:63390',
  Boolean[false]    $noop_value     = false,
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

  $_address = $listen_address.split(':')[0]
  $_port = $listen_address.split(':')[1]

  $_options = [
    "--address=${_address}",
    "--port=${_port}",
  ]

  prometheus::daemon { 'wireguard_exporter':
    package_name      => 'obmondo-wireguard-exporter',
    version           => '3.6.6',
    service_enable    => $enable,
    service_ensure    => ensure_service($enable),
    package_ensure    => ensure_latest($enable),
    init_style        => if !$enable { 'none' },
    install_method    => 'package',
    tag               => $::trusted['certname'],
    user              => 'wireguard_exporter',
    group             => 'wireguard_exporter',
    notify_service    => Service[ 'wireguard_exporter' ],
    real_download_url => 'https://github.com/MindFlavor/prometheus_wireguard_exporter',
    export_scrape_job => $enable,
    options           => $_options.join(' '),
    scrape_port       => Integer($listen_address.split(':')[1]),
    scrape_host       => $trusted['certname'],
    scrape_job_name   => 'wireguard',
    scrape_job_labels => { 'certname' => $::trusted['certname'] },
  }

  # NOTE: This is a daemon-reload, which will do a daemon-reload in noop mode.
  # upstream module cant handle noop. (which is correct)
  Exec <| tag == 'systemd-wireguard_exporter.service-systemctl-daemon-reload' |> {
    noop => $noop_value,
  }
}
