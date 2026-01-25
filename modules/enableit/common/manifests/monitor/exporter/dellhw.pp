# @summary Class for managing Prometheus dellhw exporter
#
# @param enable Boolean to enable or disable the exporter. Defaults to false.
#
# @param noop_value Boolean indicating whether to run in noop mode. Defaults to false.
#
# @param manage_repo Boolean to determine if repository should be managed. Defaults to false.
#
# @param listen_address IP address and port to listen on, in the format 'IP:port'. Defaults to '127.254.254.254:63386'.
#
class common::monitor::exporter::dellhw (
  Boolean               $enable         = false,
  Boolean               $manage_repo    = false,
  Eit_types::IPPort     $listen_address = '127.254.254.254:63386',
  Eit_types::Noop_Value $noop_value     = $common::monitor::exporter::noop_value,
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

  # NOTE: This is a temporary fix as the Dell team is working to resolve a dependency conflict where an
  # 11.3 RPM requires another package that depends on an 11.1 RPM.
  # https://www.dell.com/community/en/conversations/systems-management-general/omsa-11300-rpms-available-but-not-completely/67ab61a31c2953253c271688?page=2
  if $facts['os']['family'] == 'RedHat' {
    yum::versionlock { 'srvadmin-hapi':
      ensure  => present,
      version => '11.1.0'
    }
  }

  # NOTE: The OMSA is not supported on Debian distro. We have not added the Debian repository.
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

  Exec <| tag == 'systemd-dellhw_exporter.service-systemctl-daemon-reload' |> {
    noop        => $noop_value,
    subscribe   => File['/etc/systemd/system/dellhw_exporter.service'],
  } ~> Service['dellhw_exporter']
}
