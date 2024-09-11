# == Class: rsnapshot::service
#
# Reloads cron
class rsnapshot::service (
  $manage_cron = $rsnapshot::manage_cron
) {

  if $manage_cron {
    service { $rsnapshot::cron_service_name:
      ensure => running,
    }
  }
}
