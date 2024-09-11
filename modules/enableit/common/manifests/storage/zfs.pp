# ZFS and utilities
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
