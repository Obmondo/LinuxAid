# Xtrabackup Cron
class xtrabackup::cron inherits xtrabackup {

  $_command  = "${::xtrabackup::backup_script_location}/xtrabackup.sh"

  cron::job { 'xtrabackup':
    ensure  => $::xtrabackup::ensure_cron,
    user    => 'root',
    command => $_command,
    hour    => $::xtrabackup::cron_hour,
    minute  => $::xtrabackup::cron_minute,
    weekday => $::xtrabackup::cron_weekday,
    month   => $::xtrabackup::cron_month,
    date    => $::xtrabackup::cron_monthday,
  }
}
