# @summary Prometheus Security Exporter
#
# Collects installed packages and sends them to a Vuls server for
# vulnerability scanning. Exposes CVE metrics via Prometheus.
#
# @param enable Boolean flag to enable or disable the exporter. Defaults to false.
#
# @param noop_value Eit_types::Noop_Value flag to run in noop mode. Defaults to $common::monitor::exporter::noop_value.
#
# @param host The host certificate name, used for mTLS and scrape target. Defaults to $trusted['certname'].
#
# @param listen_host The host to listen on. Defaults to '127.254.254.254'.
#
# @param listen_port The port to listen on. Defaults to 63396.
#
# @param vuls_server_url The URL of the Vuls server to send package lists to. Defaults to 'https://vuls.obmondo.com'.
#
# @param config_file Path to the configuration YAML file. Defaults to "${common::monitor::exporter::config_dir}/security_exporter.yaml".
#
# @groups settings enable, noop_value
#
# @groups network host, listen_host, listen_port
#
# @groups configuration vuls_server_url, config_file
#
class common::monitor::exporter::security (
  Boolean               $enable          = false,
  Eit_types::Noop_Value $noop_value      = $common::monitor::exporter::noop_value,
  Eit_types::Certname   $host            = $trusted['certname'],
  Stdlib::Host          $listen_host     = '127.254.254.254',
  Stdlib::Port          $listen_port     = 63396,
  Stdlib::HTTPUrl       $vuls_server_url = 'https://vuls.obmondo.com',
  Stdlib::Absolutepath  $config_file     = "${common::monitor::exporter::config_dir}/security_exporter.yaml",
) {

  unless $enable { return() }

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
    init_style        => $facts['service_provider'],
    install_method    => 'package',
    options           => "-config=${config_file}",
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

  file { $config_file:
    ensure  => ensure_file($enable),
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => stdlib::to_yaml({
      'vuls_server'     => {
        'url'       => $vuls_server_url,
        'timeout'   => '5m',
        'cert_file' => "/etc/puppetlabs/puppet/ssl/certs/${host}.pem",
        'key_file'  => "/etc/puppetlabs/puppet/ssl/private_keys/${host}.pem",
      },
      'listen_address'  => "${listen_host}:${listen_port}",
      'scan_interval'   => '12h',
    }),
    notify  => Service["${service_name}.service"],
  }

  # NOTE: This is a daemon-reload, which will do a daemon-reload in noop mode.
  # upstream module cant handle noop. (which is correct)
  Exec <| tag == 'systemd-obmondo-security-exporter.service-systemctl-daemon-reload' |> {
    noop        => $noop_value,
    subscribe   => File["/etc/systemd/system/${service_name}.service"],
  } ~> Service[$service_name]
}
