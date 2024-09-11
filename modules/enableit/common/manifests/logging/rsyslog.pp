# rsyslog
class common::logging::rsyslog (
  Boolean                       $manage          = $common::logging::manage,
  Boolean                       $enable          = true,
  Boolean                       $purge_rsyslog_d = true,
  Boolean                       $log_remote      = false,
  Boolean                       $log_local       = true,
  Boolean                       $system_log      = $log_local,
  Boolean                       $log_cron        = true,
  Boolean                       $log_mail        = true,
  Boolean                       $log_auth        = true,
  Boolean                       $log_boot        = false,
  Eit_types::Rsyslog::Remote_Ip $remote_servers  = {},
) {

  confine($manage, $enable, $log_remote, $remote_servers.empty,
          'Remote servers must be defined if using remote logging')

  if $manage {
    include ::profile::logging::rsyslog
  }
}
