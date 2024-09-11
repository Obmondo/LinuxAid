#
class logrotate (
  String $ensure                             = present,
  Boolean $hieramerge                        = false,
  Boolean $manage_cron_daily                 = true,
  Boolean $manage_cron_hourly                = true,
  Enum[present,absent] $ensure_cron_daily    = 'present',
  Enum[present,absent] $ensure_cron_hourly   = 'present',
  Boolean $manage_systemd_timer              = false,
  Enum[present,absent] $ensure_systemd_timer = 'absent',
  Boolean $create_base_rules                 = true,
  Boolean $purge_configdir                   = false,
  String $package                            = 'logrotate',
  Hash $rules                                = {},
  Optional[Hash] $config                     = undef,
  Integer[0,23] $cron_daily_hour             = $logrotate::params::cron_daily_hour,
  Integer[0,59] $cron_daily_minute           = $logrotate::params::cron_daily_minute,
  Integer[0,59] $cron_hourly_minute          = $logrotate::params::cron_hourly_minute,
  Stdlib::Filemode $cron_file_mode           = $logrotate::params::cron_file_mode,
  String $configdir                          = $logrotate::params::configdir,
  String $logrotate_bin                      = $logrotate::params::logrotate_bin,
  String $logrotate_conf                     = $logrotate::params::logrotate_conf,
  Stdlib::Filemode $logrotate_conf_mode      = $logrotate::params::logrotate_conf_mode,
  Boolean $manage_package                    = $logrotate::params::manage_package,
  String $rules_configdir                    = $logrotate::params::rules_configdir,
  Stdlib::Filemode $rules_configdir_mode     = $logrotate::params::rules_configdir_mode,
  String $root_user                          = $logrotate::params::root_user,
  String $root_group                         = $logrotate::params::root_group,
  Array[String[1]] $logrotate_args           = [],
  Boolean $cron_always_output                = false,
) inherits logrotate::params {
  contain logrotate::install
  contain logrotate::config
  contain logrotate::rules
  contain logrotate::defaults
  contain logrotate::hourly

  Class['logrotate::install']
  -> Class['logrotate::config']
  -> Class['logrotate::rules']
  -> Class['logrotate::defaults']
}
