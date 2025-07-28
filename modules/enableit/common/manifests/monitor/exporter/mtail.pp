# @summary Class for managing the Prometheus Mtail Exporter
#
# @param enable Whether to enable the exporter. Defaults to the value of $common::monitor::exporter::enable.
#
# @param noop_value The noop value for resources. Defaults to false.
#
# @param listen_address The IP and port to listen on. Defaults to '127.254.254.254:63389'.
#
# @param logs An array of log file paths to monitor. Defaults to an empty array.
#
# @param progs The path to the programs directory. Defaults to "${common::monitor::exporter::config_dir}/mtail".
#
class common::monitor::exporter::mtail (
  Boolean                     $enable         = $common::monitor::exporter::enable,
  Boolean                     $noop_value     = false,
  Eit_types::IPPort           $listen_address = '127.254.254.254:63389',
  Array[Stdlib::Absolutepath] $logs           = [],
  Stdlib::Absolutepath        $progs          = "${common::monitor::exporter::config_dir}/mtail",
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

  $user = 'mtail_exporter'

  $parse_logs = $logs.map |$x| {
    "'-logs ${x}'"
  }.join(' ')

  $_address = $listen_address.split(':')[0]
  $_port = $listen_address.split(':')[1]

  $_extra_groups = $facts['os']['family'] ? {
    'Debian' => 'adm',
    default  => 'root',
  }

  $_options = [
    "-progs ${progs}",
    "-address ${_address}",
    "-port ${_port}",
    "-logtostderr ${parse_logs}",
  ]

  prometheus::daemon { 'mtail_exporter':
    package_name      => 'obmondo-mtail-exporter',
    version           => '0.9.3',
    service_enable    => $enable,
    service_ensure    => ensure_service($enable),
    package_ensure    => ensure_latest($enable),
    init_style        => if !$enable { 'none' },
    install_method    => 'package',
    tag               => $::trusted['certname'],
    user              => $user,
    group             => $user,
    notify_service    => Service['mtail_exporter'],
    real_download_url => 'https://github.com/madron/mtail-exporter',
    export_scrape_job => $enable,
    extra_groups      => [$_extra_groups],
    options           => $_options.join(' '),
    scrape_port       => Integer($listen_address.split(':')[1]),
    scrape_host       => $trusted['certname'],
    scrape_job_name   => 'mtail',
    scrape_job_labels => { 'certname' => $::trusted['certname'] },
  }

  # NOTE: This is a daemon-reload, which will do a daemon-reload in noop mode.
  # upstream module cant handle noop. (which is correct)
  Exec <| tag == 'systemd-mtail_exporter.service-systemctl-daemon-reload' |> {
    noop => $noop_value,
  }
}
