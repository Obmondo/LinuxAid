# == Class: saz_rsyslog::modload
#

class saz_rsyslog::modload (
  $modload_filename = '10-modload',
) {
  saz_rsyslog::snippet { $modload_filename:
    ensure  => present,
    content => template('rsyslog/modload.erb'),
    require => Class['saz_rsyslog::install'],
  }

}
