# @summary Class for managing rsyslog configuration
#
# @param manage 
# Whether to manage rsyslog. Defaults to the value of $common::logging::manage.
#
# @param enable Enable rsyslog. Defaults to true.
#
# @param purge_rsyslog_d Whether to purge rsyslog.d directory. Defaults to true.
#
# @param log_remote Enable logging remotely. Defaults to false.
#
# @param log_local Enable local logging. Defaults to true.
#
# @param system_log Use system log. Defaults to value of $log_local.
#
# @param log_cron Enable cron logging. Defaults to true.
#
# @param log_mail Enable mail logging. Defaults to true.
#
# @param log_auth Enable auth logging. Defaults to true.
#
# @param log_boot Enable boot logging. Defaults to false.
#
# @param remote_servers Hash of remote server IPs for remote logging. Defaults to an empty hash.
#
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
