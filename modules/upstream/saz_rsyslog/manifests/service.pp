# == Class: saz_rsyslog::service
#
# This class enforces running of the rsyslog service.
#
# === Parameters
#
# === Variables
#
# === Examples
#
#  class { 'saz_rsyslog::service': }
#
class saz_rsyslog::service {
  service { $saz_rsyslog::service_name:
    ensure     => running,
    enable     => true,
    hasstatus  => $saz_rsyslog::service_hasstatus,
    hasrestart => $saz_rsyslog::service_hasrestart,
    require    => Class['saz_rsyslog::config'],
  }
}
