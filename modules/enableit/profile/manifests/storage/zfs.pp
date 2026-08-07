# ZFS and utilities
class profile::storage::zfs (
  Sanoid::Pools                 $pools           = $common::storage::zfs::pools,
  Array[String]                 $allow_sync_from = $common::storage::zfs::allow_sync_from,
  Sanoid::Syncoid::Replications $replications    = $common::storage::zfs::replications,
) inherits profile::storage {

  class { 'zfs':
    kmod_type      => 'dkms',
    manage_repo    => true,
    service_manage => true,
  }

  # We need to make sure a few folders exist for all services to work. `sysstat`
  # is a dependency for ZFS for some reason.
  file { '/var/log/sa':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => 'a=rx,u+w',
  }

  # Since we already have other monitoring we don't need sar to run too
  file { '/etc/cron.d/sysstat':
    ensure => absent,
  }

  if $replications {
    class { '::sanoid':
      pools           => $pools,
      templates       => undef,
      replications    => $replications,
      allow_sync_from => $allow_sync_from,
    }
  }

  zfs::scrub { keys($pools):
    hour     => 23,
    minute   => 00,
    month    => '*',
    monthday => 1,
    weekday  => '*',
  }
}
