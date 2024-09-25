# Prometheus iptables Exporter
class common::monitor::exporter::iptables (
  Boolean           $enable         = $facts.dig('iptable_rules_exist'),
  Boolean[false]    $noop_value     = false,
  Eit_types::IPPort $listen_address = '127.254.254.254:63393',
) {
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

  Exec {
    noop => $noop_value,
  }

  $_systemd_version_232_newer = $facts.dig('systemd_version').then |$_version| { Integer($_version) } >= 232

  $_user = if $_systemd_version_232_newer { 'iptables_exporter' } else { 'root' }
  $_group = if $_systemd_version_232_newer { 'iptables_exporter' } else { 'root' }

  prometheus::daemon { 'iptables_exporter':
    package_name      => 'obmondo-iptables-exporter',
    package_ensure    => ensure_latest($enable),
    version           => '0.9.3',
    service_enable    => $enable,
    service_ensure    => ensure_service($enable),
    init_style        => if !$enable { 'none' },
    manage_user       => $_systemd_version_232_newer,
    manage_group      => $_systemd_version_232_newer,
    install_method    => 'package',
    user              => $_user,
    group             => $_group,
    notify_service    => Service['iptables_exporter'],
    real_download_url => 'https://github.com/Obmondo/iptables_exporter',
    tag               => $::trusted['certname'],
    options           => "--web.listen-address=${listen_address}",
    export_scrape_job => $enable,
    scrape_port       => Integer($listen_address.split(':')[1]),
    scrape_host       => $trusted['certname'],
    scrape_job_name   => 'iptables',
  }

  systemd::manage_dropin { 'iptables_exporter.service-90-capabilities.conf':
    unit          => 'iptables_exporter.service',
    filename      => '90-capabilities.conf',
    service_entry => {
      'CapabilityBoundingSet' => [
        'CAP_DAC_READ_SEARCH',
        'CAP_NET_ADMIN',
        'CAP_NET_RAW',
      ],
      'AmbientCapabilities'   => [
        'CAP_DAC_READ_SEARCH',
        'CAP_NET_ADMIN',
        'CAP_NET_RAW',
      ],
    },
  }

  # NOTE: This is a daemon-reload, which will do a daemon-reload in noop mode.
  # upstream module cant handle noop. (which is correct)
  Exec <| tag == 'systemd-iptables_exporter.service-systemctl-daemon-reload' |> {
    noop => $noop_value,
  }

  # The upstream module does not have support for removing the unit file
  # will rase the PR for that later will remove from this resources file
  if !$enable {
    File { '/etc/systemd/system/iptables_exporter.service':
      ensure => absent,
    }
  }
}
