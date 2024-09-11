# ZFS and utilities
class profile::storage::zfs (
  Array[Eit_types::SimpleString]                  $pool_names          = $::common::storage::zfs::pool_names,
  Boolean                                         $remove_sysstat_cron = $::common::storage::zfs::remove_sysstat_cron,
  Eit_types::Common::Storage::Zfs::Scrub_interval $scrub               = $::common::storage::zfs::scrub,
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

    zfs::scrub { $pool_names:
      hour   => 23,
      minute => 00,
      month  => '*',
      *      => $_config,
    }
  }

}
