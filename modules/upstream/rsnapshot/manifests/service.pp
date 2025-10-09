# == Class: rsnapshot::service
#
# Reloads cron 
class rsnapshot::service {
  service { $rsnapshot::cron_service_name:
    ensure => running,
  }

}

