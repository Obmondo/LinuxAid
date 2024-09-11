# == Class: rsnapshot::install
#
# Installs the rsnapshot package.
class rsnapshot::install {
  case $::operatingsystem {
    /^CentOS$/: { include epel }
    default: {}
  }
  package { $rsnapshot::package_name:
    ensure => $rsnapshot::package_ensure,
  }

}

