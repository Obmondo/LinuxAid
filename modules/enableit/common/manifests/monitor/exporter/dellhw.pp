# Prometheus dellhw Exporter
class common::monitor::exporter::dellhw (
  Boolean           $enable         = false,
  Boolean[false]    $noop_value     = false,
  Boolean           $manage_repo    = false,
  Eit_types::IPPort $listen_address = '127.254.254.254:63386',
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

  package { ['dell-system-update','srvadmin-all']:
    ensure => ensure_present($enable),
    noop   => $noop_value,
  }

  # NOTE: The OMSA is not supported on Debian distro. We have not added the debain repository
  # https://linux.dell.com/repo/community/openmanage/

  if $manage_repo {
    eit_repos::repo { 'dell':
      ensure     => $enable,
      noop_value => $noop_value,
    }
  }

  class { 'prometheus::dellhw_exporter':
    package_name      => 'obmondo-dellhw-exporter',
    package_ensure    => ensure_latest($enable),
    service_enable    => $enable,
    service_ensure    => ensure_service($enable),
    manage_service    => $enable,
    init_style        => if !$enable {'none'},
    restart_on_change => $enable,
    export_scrape_job => $enable,
    scrape_port       => Integer($listen_address.split(':')[1]),
    scrape_ipadress   => $listen_address.split(':')[0],
    tag               => $::trusted['certname'],
    scrape_host       => $::trusted['certname'],
    scrape_job_labels => { 'certname' => $::trusted['certname'] },
  }
}
