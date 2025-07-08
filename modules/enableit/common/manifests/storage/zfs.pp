# @summary Class for managing ZFS storage and utilities
#
# @param enable Boolean indicating if ZFS should be enabled. Defaults to false.
#
# @param pool_names List of pool names for ZFS pools. Defaults to an empty array.
#
# @param remove_sysstat_cron Boolean to remove sysstat cron jobs. Defaults to true.
#
# @param scrub Interval for ZFS scrubbing. Defaults to 'monthly'.
#
class common::storage::zfs (
  Boolean                                         $enable              = false,
  Array[Eit_types::SimpleString]                  $pool_names          = [],
  Boolean                                         $remove_sysstat_cron = true,
  Eit_types::Common::Storage::Zfs::Scrub_interval $scrub               = 'monthly',
) inherits common::storage {
  if $enable {
    include profile::storage::zfs
  }
}
