# ZFS and utilities
class profile::storage::zfs (
  Boolean                       $remove_sysstat_cron = $common::storage::zfs::remove_sysstat_cron,
  Sanoid::Pools                 $pools               = $common::storage::zfs::pools,
  Array[String]                 $allow_sync_from     = $common::storage::zfs::allow_sync_from,
  Optional[Sanoid::Templates]   $templates           = $common::storage::zfs::templates,
  Sanoid::Syncoid::Replications $replications        = $common::storage::zfs::replications,

  Eit_types::Common::Storage::Zfs::Scrub_interval $scrub = $common::storage::zfs::scrub,
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
  if $remove_sysstat_cron {
    file { '/etc/cron.d/sysstat':
      ensure => absent,
    }
  }

  if $replications {
    class { '::sanoid':
      pools           => $pools,
      templates       => $templates,
      replications    => $replications,
      allow_sync_from => $allow_sync_from,
    }
  }

  if $scrub {
    $_config = $scrub ? {
      'monthly' => {
        monthday => 1,
        weekday  => '*',
      },
      'weekly' => {
        monthday => '*',
        weekday  => 5,
      },
      'daily' => {
        hour     => 23,
        monthday => '*',
        weekday  => '*',
      },
    }

    zfs::scrub { keys($pools):
      hour   => 23,
      minute => 00,
      month  => '*',
      *      => $_config,
    }
  }
}
