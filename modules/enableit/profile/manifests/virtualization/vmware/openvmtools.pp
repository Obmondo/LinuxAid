# Setup openvmtools on the guest.
class profile::virtualization::vmware::openvmtools (
  Boolean $ensure      = $common::virtualization::vmware::openvmtools::ensure,
  Boolean $autoupgrade = $common::virtualization::vmware::openvmtools::autoupgrade,
) {

  if $ensure {
    class { '::openvmtools':
      ensure      => ensure_present($ensure),
      autoupgrade => $autoupgrade,
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
