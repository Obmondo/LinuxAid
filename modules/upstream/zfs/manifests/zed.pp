# Installs the ZFS Event Daemon.
#
# @example Declaring the class
#   include zfs
#   include zfs::zed
#
# @param conf_dir Configuration directory, usually `${zfs::conf_dir}/zed.d`.
# @param debug_log
# @param email_addrs
# @param email_opts
# @param email_prog
# @param lock_dir
# @param notify_interval_secs
# @param notify_verbose
# @param package_name The name of the package to install if not installed
#   already by the ZFS class.
# @param pushbullet_access_token
# @param pushbullet_channel_tag
# @param run_dir
# @param service_manage Whether to manage the service.
# @param service_name Name of the service.
# @param spare_on_checksum_errors
# @param spare_on_io_errors
# @param syslog_priority
# @param syslog_tag
# @param use_enclosure_leds
# @param zedlet_dir Path to package-provided zedlets.
# @param zedlets Hash of zedlet resources to create.
#
# @see puppet_classes::zfs zfs
# @see puppet_defined_types::zfs::zed::zedlet zfs::zed::zedlet
#
# @since 2.0.0
class zfs::zed (
  Stdlib::Absolutepath           $conf_dir,
  Optional[Stdlib::Absolutepath] $debug_log,
  Optional[Array[String, 1]]     $email_addrs,
  Optional[String]               $email_opts,
  Optional[String]               $email_prog,
  Optional[Stdlib::Absolutepath] $lock_dir,
  Optional[Integer[0]]           $notify_interval_secs,
  Optional[Boolean]              $notify_verbose,
  Optional[String]               $package_name,
  Optional[String]               $pushbullet_access_token,
  Optional[String]               $pushbullet_channel_tag,
  Optional[Stdlib::Absolutepath] $run_dir,
  Boolean                        $service_manage,
  String                         $service_name,
  Optional[Integer[1]]           $spare_on_checksum_errors,
  Optional[Integer[1]]           $spare_on_io_errors,
  Optional[String]               $syslog_priority,
  Optional[String]               $syslog_tag,
  Optional[Boolean]              $use_enclosure_leds,
  Stdlib::Absolutepath           $zedlet_dir,
  Hash[String, Hash]             $zedlets,
) {

  include zfs

  contain zfs::zed::install
  contain zfs::zed::config
  contain zfs::zed::service

  Class['zfs::service'] -> Class['zfs::zed::install']
    -> Class['zfs::zed::config'] ~> Class['zfs::zed::service']
}
