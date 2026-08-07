# Setup openvmtools on the guest.
class profile::virtualization::vmware::openvmtools (
  Boolean $ensure = $common::software::openvmtools::ensure,
) {

  if $ensure {
    class { '::openvmtools':
      ensure      => ensure_present($ensure),
      autoupgrade => true,
      supported   => true,
    }
  } else {

  # NOTE: The upstream dosen't remove the package if its not vmware server.
  # So adding condition for removing the package.
    package { 'open-vm-tools':
      ensure => 'purged',
    }

    service { 'open-vm-tools':
      ensure  => stopped,
      enable  => false,
      require => Package[ 'open-vm-tools' ],
    }
  }
}
