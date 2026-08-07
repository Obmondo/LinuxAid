# @summary Class for managing the Prometheus Slurm Exporter
#
# @param noop_value Whether to run in noop mode. Defaults to false.
#
# @groups settings noop_value
#
class common::monitor::exporter::slurm (
  Eit_types::Noop_Value $noop_value = $common::monitor::exporter::noop_value,
) {
  $enable = $common::monitor::exporter::enable

  unless $enable { return() }

  $listen_address = '127.254.254.254:63397'

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

  prometheus::daemon { 'slurm_exporter':
    package_name      => 'obmondo-slurm-exporter',
    version           => '1.9.1',
    service_enable    => $enable,
    service_ensure    => ensure_service($enable),
    package_ensure    => ensure_latest($enable),
    init_style        => $facts['service_provider'],
    install_method    => 'package',
    tag               => $::trusted['certname'],
    user              => 'slurm_exporter',
    group             => 'slurm_exporter',
    notify_service    => Service['slurm_exporter'],
    real_download_url => 'https://github.com/sckyzo/slurm_exporter',
    export_scrape_job => $enable,
    options           => "--web.listen-address=${listen_address}",
    scrape_port       => Integer($listen_address.split(':')[1]),
    scrape_host       => $trusted['certname'],
    scrape_job_name   => 'slurm',
    scrape_job_labels => { 'certname' => $::trusted['certname'] },
  }

  # NOTE: This is a daemon-reload, which will do a daemon-reload in noop mode.
  # upstream module can't handle noop. (which is correct)
  Exec <| tag == 'systemd-slurm_exporter.service-systemctl-daemon-reload' |> {
    noop      => $noop_value,
    subscribe => File['/etc/systemd/system/slurm_exporter.service'],
  } ~> Service['slurm_exporter']
}
