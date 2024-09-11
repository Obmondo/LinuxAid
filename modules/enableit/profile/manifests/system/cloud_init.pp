# cloud-init package we must run on cloud instance only, but not on physical/vmware server
# f.x azure has some mount point which depends on cloud-init, if cloud-init is not running
# mountpoint will not be mounted.

# since we have earlier masked all the cloud-init service and I really dont want to touch
# existing node, so lets have the existing node as it is and enable as an when we required, so
# someone is doing manually and I expect they know what they are doing it.
class profile::system::cloud_init (
  Boolean $enable   = $common::system::cloud_init::manage,
  Array   $services = $common::system::cloud_init::services,
) inherits ::profile::system {

  # Lets disable network management via cloud-init and lets manage it via puppet
  file { '/etc/cloud/cloud.cfg.d/99-disable-network-config.cfg' :
    ensure  => ensure_present(
      (lookup('common::network::service_name') == 'systemd-networkd')
      and
      (lookup('common::network::manage', Boolean, undef, false))
    ),
    content => 'network: {config: disabled}',
  }

  if $enable {
    package { 'cloud-init':
      ensure => ensure_present($enable),
    }

    service { $services:
      ensure  => $enable,
      require => Package['cloud-init'],
    }
  }
}
