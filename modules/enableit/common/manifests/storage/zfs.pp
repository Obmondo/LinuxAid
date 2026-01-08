# @summary Class for managing ZFS storage and utilities
#
# @param enable Boolean indicating if ZFS should be enabled. Defaults to false.
#
# @param remove_sysstat_cron Boolean to remove sysstat cron jobs. Defaults to true.
#
# @param scrub Interval for ZFS scrubbing. Defaults to 'monthly'.
#
# @param allow_sync_from List of authorized sync sources.
#
# @param pools ZFS storage pool configurations.
#
# @param templates Templates for pool setup.
#
# @param replications Configurations for data replications.
#
# @groups general enable, remove_sysstat_cron, scrub
#
# @groups replication allow_sync_from, pools, templates, replications
#
class common::storage::zfs (
  Boolean                       $enable              = false,
  Boolean                       $remove_sysstat_cron = true,
  Array[String]                 $allow_sync_from     = [],
  Sanoid::Pools                 $pools               = {},
  Optional[Sanoid::Templates]   $templates           = undef,
  Sanoid::Syncoid::Replications $replications        = {},

  Eit_types::Common::Storage::Zfs::Scrub_interval $scrub = 'monthly',
) inherits common::storage {

  if $enable {
    include profile::storage::zfs
  }
}
