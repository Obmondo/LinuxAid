# Prometheus Security Exporter
#
# @param enable Boolean flag to enable or disable the exporter. Defaults to false.
#
# @param noop_value Eit_types::Noop_Value flag to run in noop mode. Defaults to $common::monitor::exporter::noop_value.
#
# @param host The host certificate name. Defaults to $trusted['certname'].
#
# @param listen_host The host to listen on. Defaults to '127.254.254.254'.
#
# @param listen_port The port to listen on. Defaults to 63396.
#
# @param config_file Path to the configuration YAML file. Defaults to "${common::monitor::exporter::config_dir}/security_exporter.yaml".
#
class common::monitor::exporter::security (
  Boolean               $enable      = false,
  Eit_types::Noop_Value $noop_value  = $common::monitor::exporter::noop_value,
  Eit_types::Certname   $host        = $trusted['certname'],
  Stdlib::Host          $listen_host = '127.254.254.254',
  Stdlib::Port          $listen_port = 63396,
  Stdlib::Absolutepath  $config_file = "${common::monitor::exporter::config_dir}/security_exporter.yaml"
) {

  $service_name = 'obmondo-security-exporter'

  Package {
    noop => $noop_value,
  }

  Service {
    noop => $noop_value,
  }

  File {
    noop => $noop_value,
  }

  Exec {
    noop => $noop_value,
  }

  if (($facts['os']['name'] == 'RedHat' or $facts['os']['name'] == 'CentOS') and (Integer($facts['os']['release']['major']) < 7)){
    package { 'yum-plugin-changelog':
      ensure => ensure_latest($enable),
    }

    package { 'yum-plugin-security':
      ensure => ensure_latest($enable),
    }
  }

  service { "${service_name}.service":
    ensure  => ensure_service($enable),
    enable  => $enable,
    require => Package[$service_name],
  }

  prometheus::daemon { $service_name:
    package_name      => $service_name,
    version           => '1.0.0', # dummy entry
    service_enable    => $enable,
    real_download_url => 'https://gitea.obmondo.com/EnableIT/security-exporter',
    service_ensure    => ensure_service($enable),
    package_ensure    => ensure_latest($enable),
    init_style        => if !$enable { 'none' },
    install_method    => 'package',
    tag               => $::trusted['certname'],
    notify_service    => Service[$service_name],
    group             => 'root',
    user              => 'root',
    manage_user       => false,
    manage_group      => false,
    export_scrape_job => $enable,
    scrape_port       => Integer($listen_port),
    scrape_host       => $host,
    scrape_job_name   => 'security',
    scrape_job_labels => { 'certname' => $::trusted['certname'] },
  }

  $_service = @("EOT"/$n)
    # THIS FILE IS MANAGED BY OBMONDO. CHANGES WILL BE LOST.
    [Service]
    ExecStart=
    ExecStart=/opt/obmondo/bin/obmondo-security-exporter -config=${config_file}
    | EOT

  systemd::dropin_file { "${service_name}_dropin":
    ensure   => ensure_file($enable),
    filename => "${service_name}-override.conf",
    unit     => "${service_name}.service",
    content  => $_service,
    notify   => Service["${service_name}.service"],
  }

  file { $config_file:
    ensure  => ensure_file($enable),
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => epp(
      'common/monitor/exporter/security_exporter.yaml.epp', {
        cve_api_url => 'https://services.nvd.nist.gov',
        server_host => $listen_host,
        server_port => $listen_port,
        cron_expr   => '00 23 * * *',
      },
    ),
    notify  => Service["${service_name}.service"],
  }

  # NOTE: This is a daemon-reload, which will do a daemon-reload in noop mode.
  # upstream module cant handle noop. (which is correct)
  Exec <| tag == 'systemd-obmondo-security-exporter.service-systemctl-daemon-reload' |> {
    noop        => $noop_value,
    subscribe   => File["/etc/systemd/system/${service_name}.service"],
  } ~> Service[$service_name]
}
