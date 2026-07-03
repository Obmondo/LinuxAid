# @summary Class for managing the Prometheus ZFS exporter
#
# @param enable Whether to enable the exporter.
#
# @param listen_address The IP and port to listen on, in the format 'IP:port'. Defaults to '127.254.254.254:63394'.
#
# @param noop_value Whether to perform noop actions. Defaults to false.
#
# @param exclude Regexes for datasets/snapshots/volumes that should be excluded from collection.
#
# @param scrape_job_labels Extra labels to attach to the exported Prometheus scrape job.
#
# @groups settings enable, noop_value
#
# @groups network listen_address
#
# @groups collection exclude, scrape_job_labels
#
class common::monitor::exporter::zfs (
  Boolean               $enable         = false,
  Eit_types::IPPort     $listen_address = '127.254.254.254:63394',
  Eit_types::Noop_Value $noop_value     = $common::monitor::exporter::noop_value,
  Array[String[1]]      $exclude        = ['@autosnap_'],
  Hash[String[1], String[1]] $scrape_job_labels = {},
) {
  unless $enable { return() }

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

  $_exclude_options = $exclude.map |String[1] $pattern| {
    "--exclude=${pattern}"
  }

  $_options = [
    "--web.listen-address=${listen_address}",
    '--properties.pool=health',
    '--no-collector.dataset-filesystem',
    '--collector.dataset-snapshot',
    '--properties.dataset-snapshot=creation',
    '--no-collector.dataset-volume',
    $_exclude_options,
  ].flatten

  prometheus::daemon { 'zfs_exporter':
    package_name      => 'obmondo-zfs-exporter',
    package_ensure    => ensure_latest($enable),
    version           => '2.3.12',
    service_enable    => $enable,
    service_ensure    => ensure_service($enable),
    manage_user       => false,
    manage_group      => false,
    init_style        => $facts['service_provider'],
    install_method    => 'package',
    tag               => $::trusted['certname'],
    user              => 'root',
    group             => 'root',
    notify_service    => Service['zfs_exporter'],
    real_download_url => 'https://github.com/pdf/zfs_exporter',
    export_scrape_job => $enable,
    options           => $_options.join(' '),
    scrape_port       => Integer($listen_address.split(':')[1]),
    scrape_host       => $trusted['certname'],
    scrape_job_name   => 'zfs',
    scrape_job_labels => { 'certname' => $::trusted['certname'] } + $scrape_job_labels,
  }

  # NOTE: This is a daemon-reload, which will do a daemon-reload in noop mode.
  # upstream module can't handle noop. (which is correct)
  Exec <| tag == 'systemd-zfs_exporter.service-systemctl-daemon-reload' |> {
    noop      => $noop_value,
    subscribe => File['/etc/systemd/system/zfs_exporter.service'],
  } ~> Service['zfs_exporter']
}
