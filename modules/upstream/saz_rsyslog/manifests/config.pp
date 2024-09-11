# == Class: saz_rsyslog::config
#
# Full description of class role here.
#
# === Parameters
#
# === Variables
#
# === Examples
#
#  class { 'saz_rsyslog::config': }
#
class saz_rsyslog::config {

  File {
    owner   => 'root',
    group   => $saz_rsyslog::run_group,
    require => Class['saz_rsyslog::install'],
    notify  => Class['saz_rsyslog::service'],
  }

  file { $saz_rsyslog::rsyslog_d:
    ensure  => directory,
    purge   => $saz_rsyslog::purge_rsyslog_d,
    recurse => true,
    force   => true,
  }

  file { $saz_rsyslog::rsyslog_conf:
    ensure  => file,
    content => template("${module_name}/rsyslog.conf.erb"),
  }

  file { $saz_rsyslog::rsyslog_default:
    ensure  => file,
    content => template("${module_name}/${saz_rsyslog::rsyslog_default_file}.erb"),
  }

  file { $saz_rsyslog::spool_dir:
    ensure  => directory,
    owner   => $saz_rsyslog::run_user,
    mode    => '0700',
    seltype => 'syslogd_var_lib_t',
  }

}
