# == Class: saz_rsyslog::install
#
# This class makes sure that the required packages are installed
#
# === Parameters
#
# === Variables
#
# === Examples
#
#  class { 'saz_rsyslog::install': }
#
class saz_rsyslog::install {
  if $saz_rsyslog::rsyslog_package_name != false {
    package { $saz_rsyslog::rsyslog_package_name:
      ensure => $saz_rsyslog::package_status,
      notify => Class['saz_rsyslog::service'],
    }
  }

  if $saz_rsyslog::relp_package_name != false {
    package { $saz_rsyslog::relp_package_name:
      ensure => $saz_rsyslog::package_status,
      notify => Class['saz_rsyslog::service'],
    }
  }

  if $saz_rsyslog::gnutls_package_name != false {
    package { $saz_rsyslog::gnutls_package_name:
      ensure => $saz_rsyslog::package_status,
      notify => Class['saz_rsyslog::service'],
    }
  }

}
