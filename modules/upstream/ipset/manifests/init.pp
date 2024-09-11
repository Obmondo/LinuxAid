# @summary module to install the ipset tooling and to manage individual ipsets
#
# @param packages
#   The name of the package we want to install
#
# @param service
#   The name of the service that we're going to manage
#
# @param service_ensure
#   Desired state of the service. If true, the service will be running. If false, the service will be stopped
#
# @param enable
#   Boolean to decide if we want to have the service in autostart or not
#
# @param firewall_service
#   An optional service name. if provided, the ipsets will be configured before this. So your firewall will depend on the chains. The name should end with `.service`. This is only supported on systemd-based Operating Systems
#
class ipset (
  Array[String[1]] $packages,
  String[1] $service,
  Boolean $service_ensure,
  Boolean $enable,
  Enum['present', 'absent', 'latest'] $package_ensure,
  Stdlib::Absolutepath $config_path,
  Optional[Pattern[/\.service$/]] $firewall_service = undef,
){
  package{$ipset::packages:
    ensure => $package_ensure,
  }

  # create the config directory
  file{$config_path:
    ensure => 'directory',
  }

  # setup the helper scripts
  file{'/usr/local/bin/ipset_sync':
    ensure => 'file',
    owner  => 'root',
    group  => 'root',
    mode   => '0754',
    source => "puppet:///modules/${module_name}/ipset_sync",
  }
  file{'/usr/local/bin/ipset_init':
    ensure => 'file',
    owner  => 'root',
    group  => 'root',
    mode   => '0754',
    source => "puppet:///modules/${module_name}/ipset_init",
  }

  # configure custom unit file
  case $facts['service_provider'] {
    'systemd': {
      systemd::unit_file{"${service}.service":
        enable    => $enable,
        active    => $service_ensure,
        content   => epp("${module_name}/ipset.service.epp",{
          'firewall_service' => $firewall_service,
          'config_path'      => $config_path,
          }),
        subscribe => [File['/usr/local/bin/ipset_init'], File['/usr/local/bin/ipset_sync']],
      }
    }
    'redhat': {
      file{'/etc/init.d/ipset':
        ensure  => 'file',
        mode    => '0755',
        content => epp("${module_name}/init.redhat.epp", {
          'config_path' => $config_path
          }
        ),
        require => Package[$ipset::packages],
      }
      -> service{'ipset':
        ensure => 'running',
        enable => true,
      }
    }
    default: {
      fail('The ipset module only supports systemd and RedHat 6 based distributions')
    }
  }
}
