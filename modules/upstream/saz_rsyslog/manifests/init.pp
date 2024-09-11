# == Class: rsyslog
#
# Meta class to install rsyslog with a basic configuration.
# You probably want saz_rsyslog::client or saz_rsyslog::server
#
# === Parameters
#
# === Variables
#
# === Examples
#
#  class { 'rsyslog': }
#
class saz_rsyslog (
  $rsyslog_package_name                = $saz_rsyslog::params::rsyslog_package_name,
  $relp_package_name                   = $saz_rsyslog::params::relp_package_name,
  $mysql_package_name                  = $saz_rsyslog::params::mysql_package_name,
  $pgsql_package_name                  = $saz_rsyslog::params::pgsql_package_name,
  $gnutls_package_name                 = $saz_rsyslog::params::gnutls_package_name,
  $package_status                      = $saz_rsyslog::params::package_status,
  $rsyslog_d                           = $saz_rsyslog::params::rsyslog_d,
  $purge_rsyslog_d                     = $saz_rsyslog::params::purge_rsyslog_d,
  $rsyslog_conf                        = $saz_rsyslog::params::rsyslog_conf,
  $rsyslog_default                     = $saz_rsyslog::params::rsyslog_default,
  $rsyslog_default_file                = $saz_rsyslog::params::default_config_file,
  $run_user                            = $saz_rsyslog::params::run_user,
  $run_group                           = $saz_rsyslog::params::run_group,
  $log_user                            = $saz_rsyslog::params::log_user,
  $log_group                           = $saz_rsyslog::params::log_group,
  $log_style                           = $saz_rsyslog::params::log_style,
  $umask                               = $saz_rsyslog::params::umask,
  $perm_file                           = $saz_rsyslog::params::perm_file,
  $perm_dir                            = $saz_rsyslog::params::perm_dir,
  $spool_dir                           = $saz_rsyslog::params::spool_dir,
  $service_name                        = $saz_rsyslog::params::service_name,
  $service_hasrestart                  = $saz_rsyslog::params::service_hasrestart,
  $service_hasstatus                   = $saz_rsyslog::params::service_hasstatus,
  $modules                             = $saz_rsyslog::params::modules,
  $preserve_fqdn                       = $saz_rsyslog::params::preserve_fqdn,
  $local_host_name                     = undef,
  $max_message_size                    = $saz_rsyslog::params::max_message_size,
  $system_log_rate_limit_interval      = $saz_rsyslog::params::system_log_rate_limit_interval,
  $system_log_rate_limit_burst         = $saz_rsyslog::params::system_log_rate_limit_burst,
  $extra_modules                       = $saz_rsyslog::params::extra_modules,
  $default_template_customisation      = $saz_rsyslog::params::default_template_customisation,
  $default_template                    = $saz_rsyslog::params::default_template,
  $msg_reduction                       = $saz_rsyslog::params::msg_reduction,
  $non_kernel_facility                 = $saz_rsyslog::params::non_kernel_facility,
  $omit_local_logging                  = $saz_rsyslog::params::omit_local_logging,
  $im_journal_ratelimit_interval       = $saz_rsyslog::params::im_journal_ratelimit_interval,
  $im_journal_statefile                = $saz_rsyslog::params::im_journal_statefile,
  $im_journal_ratelimit_burst          = $saz_rsyslog::params::im_journal_ratelimit_burst,
  $im_journal_ignore_previous_messages = $saz_rsyslog::params::im_journal_ignore_previous_messages
) inherits saz_rsyslog::params {

  contain saz_rsyslog::install
  contain saz_rsyslog::config
  contain saz_rsyslog::service

  if $extra_modules != [] {
    include saz_rsyslog::modload
  }

  Class['saz_rsyslog::install'] -> Class['saz_rsyslog::config'] ~> Class['saz_rsyslog::service']

}

