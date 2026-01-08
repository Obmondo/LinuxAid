# @summary Class for managing Prometheus Systemd Exporter
#
# @param enable
# Whether to enable the exporter. Defaults to the value of $common::monitor::exporter::enable.
#
# @param noop_value Whether to perform noop actions. Defaults to false.
#
# @param listen_address
# The IP and port to listen on. Defaults to '127.254.254.254:63391'.
#
# @groups main enable, noop_value
#
# @groups network listen_address
#
class common::monitor::exporter::systemd (
  Boolean               $enable         = $common::monitor::exporter::enable,
  Eit_types::Noop_Value $noop_value     = $common::monitor::exporter::noop_value,
  Eit_types::IPPort     $listen_address = '127.254.254.254:63391',
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

  prometheus::daemon { 'systemd_exporter':
    package_name      => 'obmondo-systemd-exporter',
    version           => '0.7.0',
    service_enable    => $enable,
    service_ensure    => ensure_service($enable),
    manage_service    => $enable,
    notify_service    => Service['systemd_exporter'],
    real_download_url => 'https://github.com/povilasv/systemd_exporter',
    user              => 'systemd_exporter',
    group             => 'systemd_exporter',
    init_style        => if !$enable { 'none' },
    export_scrape_job => $enable,
    options           => "--web.listen-address=${listen_address} --web.max-requests=20",
    tag               => $::trusted['certname'],
    scrape_port       => Integer($listen_address.split(':')[1]),
    scrape_host       => $trusted['certname'],
    scrape_job_labels => { 'certname' => $::trusted['certname'] },
    scrape_job_name   => 'systemd',
    package_ensure    => ensure_latest($enable),
  }
  # NOTE: This is a daemon-reload, which will do a daemon-reload in noop mode.
  # upstream module cant handle noop. (which is correct)
  Exec <| tag == 'systemd-systemd_exporter.service-systemctl-daemon-reload' |> {
    noop        => $noop_value,
    subscribe   => File['/etc/systemd/system/systemd_exporter.service'],
  } ~> Service['systemd_exporter']
}
