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
# @param datasets Properties to set on ZFS datasets, keyed by dataset name, as `zfs`
# resource attributes (e.g. `acltype: posix`). Managed even when `enable` is false, so
# hosts whose ZFS is installed outside LinuxAid (e.g. using KubeAid StorageCTL) can use
# it; skipped on hosts without ZFS. Defaults to {}.
#
# @groups general enable
#
# @groups replication allow_sync_from, pools, replications
#
# @groups datasets datasets
#
class common::storage::zfs (
  Boolean                       $enable          = false,
  Array[String]                 $allow_sync_from = [],
  Sanoid::Pools                 $pools           = {},
  Sanoid::Syncoid::Replications $replications    = {},
  Hash[String, Hash]            $datasets        = {},
) inherits common::storage {

  if $enable {
    include profile::storage::zfs
  }

  if $facts['zfs_version'] {
    $datasets.each |$_dataset, $_properties| {
      zfs { $_dataset:
        * => $_properties,
      }
    }
  }
}
