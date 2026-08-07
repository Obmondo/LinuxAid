# @summary Class for managing ZFS storage and utilities
#
# @param enable Boolean indicating if ZFS should be enabled. Defaults to false.
#
# @param allow_sync_from List of authorized sync sources.
#
# @param pools ZFS storage pool configurations.
#
# @param replications Configurations for data replications.
#
# @groups general enable
#
# @groups replication allow_sync_from, pools, replications
#
class common::storage::zfs (
  Boolean                       $enable          = false,
  Array[String]                 $allow_sync_from = [],
  Sanoid::Pools                 $pools           = {},
  Sanoid::Syncoid::Replications $replications    = {},
) inherits common::storage {

  if $enable {
    include profile::storage::zfs
  }
}
