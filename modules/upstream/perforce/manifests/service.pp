# =Class perforce::service
#
# ==Description
# Installs and starts the perforce service
#
class perforce::service {

  # start and enable p4d service
  service { 'p4d':
    ensure => 'running',
    enable => true,
  }

  # From 2025.1, p4-server-control ships p4dctl.service, which starts the
  # same p4d instance at boot. Both then race for the port and p4d.service
  # can fail. Only the boot start is disabled: stopping p4dctl.service would
  # stop the running p4d.
  if versioncmp($perforce::version.split('-')[0], '2025.1') >= 0 {
    service { 'p4dctl':
      enable  => false,
      require => Package[$perforce::packages],
    }
  }

}
