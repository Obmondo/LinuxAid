# == Class: rsnapshot
#
# Manages rsnapshot.
#
# === Parameters
#
class rsnapshot (
  $hosts                         = $rsnapshot::params::hosts,
  $conf_d                        = $rsnapshot::params::conf_d,
  $logpath                       = $rsnapshot::params::config_logpath,
  $lockpath                      = $rsnapshot::params::config_lockpath,
  $default_backup                = $rsnapshot::params::config_default_backup,
  $package_name                  = $rsnapshot::params::package_name,
  $package_ensure                = $rsnapshot::params::package_ensure,
  $cron                          = $rsnapshot::params::cron,
  $backup_scripts                = $rsnapshot::params::backup_scripts,
  $include                       = $rsnapshot::params::config_include,
  $exclude                       = $rsnapshot::params::config_exclude,
  $snapshot_root                 = $rsnapshot::params::config_snapshot_root,
  $backup_levels                 = $rsnapshot::params::config_backup_levels,
  $cron_service_name             = $rsnapshot::params::cron_service_name,
) inherits rsnapshot::params {

  $default_backup_scripts = $rsnapshot::params::backup_scripts + $backup_scripts
  $default_exclude        = $rsnapshot::params::config_exclude + $exclude
  if $hosts {
    class { '::rsnapshot::install': }->
    class { '::rsnapshot::config': }~>
    class { '::rsnapshot::service': }
    contain '::rsnapshot::install'
    contain '::rsnapshot::config'
    contain '::rsnapshot::service'
  }
}

