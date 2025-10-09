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

}