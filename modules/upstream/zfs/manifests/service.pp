# @!visibility private
class zfs::service {

  if $zfs::service_manage {

    # The ZFS SysV init scripts are all guarded with checking if the ZFS
    # module is loaded and return 0 if it's not. However returning 0 for
    # `service foo status` indicates it's running so Puppet will think the
    # services are all running and therefore never try to start them
    exec { 'modprobe zfs':
      path   => $facts['path'],
      unless => 'grep -q "^zfs " /proc/modules',
    }

    case $facts['service_provider'] {
      'systemd': {
        $cache_ensure = str2bool($facts['zfs_zpool_cache_present']) ? {
          true    => 'running',
          default => 'stopped',
        }

        $scan_ensure = str2bool($facts['zfs_zpool_cache_present']) ? {
          true    => 'stopped',
          default => 'running',
        }

        service { 'zfs-import-cache':
          ensure     => $cache_ensure,
          enable     => true,
          hasstatus  => true,
          hasrestart => true,
          require    => Exec['modprobe zfs'],
          before     => Service['zfs-mount'],
        }

        service { 'zfs-import-scan':
          ensure     => $scan_ensure,
          enable     => true,
          hasstatus  => true,
          hasrestart => true,
          require    => Exec['modprobe zfs'],
          before     => Service['zfs-mount'],
        }
      }
      default: {

        case $facts['os']['family'] {
          'RedHat': {
            service { 'zfs-import':
              ensure     => running,
              enable     => true,
              hasstatus  => true,
              hasrestart => true,
              require    => Exec['modprobe zfs'],
              before     => Service['zfs-mount'],
            }
          }
          'Debian': {
            $import_ensure = str2bool($facts['zfs_zpool_cache_present']) ? {
              true    => 'running',
              default => 'stopped',
            }

            service { 'zpool-import':
              ensure     => $import_ensure,
              enable     => true,
              hasstatus  => true,
              hasrestart => true,
              require    => Exec['modprobe zfs'],
            }
          }
          default: {
            # noop
          }
        }
      }
    }

    service { 'zfs-mount':
      ensure     => running,
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
      before     => Service['zfs-share'],
    }

    service { 'zfs-share':
      ensure     => running,
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
    }
  }
}
