# @summary Class for managing NTP Exporter
#
# @param noop_value Optional boolean to specify noop mode. Defaults to undef.
#
# @groups settings noop_value
#
class common::monitor::exporter::ntp (
  Eit_types::Noop_Value $noop_value = $common::monitor::exporter::noop_value,
) {
  $enable = $common::monitor::exporter::enable

  unless $enable { return() }

  $listen_address = '127.254.254.254:9559'

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
  $_options = [
    '-ntp.source http',
    "-web.listen-address ${listen_address}",
    '-web.telemetry-path /metrics?target=ntp.ubuntu.com&protocol=4&duration=10s',
  ]
  prometheus::daemon { 'ntp_exporter':
    package_name      => 'obmondo-ntp-exporter',
    version           => '1.1.3',
    service_enable    => $enable,
    service_ensure    => ensure_service($enable),
    package_ensure    => ensure_latest($enable),
    init_style        => $facts['service_provider'],
    install_method    => 'package',
    tag               => $::trusted['certname'],
    user              => 'ntp_exporter',
    group             => 'ntp_exporter',
    notify_service    => Service[ 'ntp_exporter' ],
    real_download_url => 'https://github.com/sapcc/ntp_exporter',
    export_scrape_job => $enable,
    options           => $_options.join(' '),
    scrape_port       => Integer($listen_address.split(':')[1]),
    scrape_host       => $::trusted['certname'],
    scrape_job_name   => 'ntp',
    scrape_job_labels => { 'certname' => $::trusted['certname'] },
  }
  # NOTE: This is a daemon-reload, which will do a daemon-reload in noop mode.
  # upstream module cant handle noop. (which is correct)
  Exec <| tag == 'systemd-ntp_exporter.service-systemctl-daemon-reload' |> {
    noop        => $noop_value,
    subscribe   => File['/etc/systemd/system/ntp_exporter.service'],
  } ~> Service['ntp_exporter']
}
