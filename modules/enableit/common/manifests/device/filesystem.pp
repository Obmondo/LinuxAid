# @summary Class for managing filesystem devices and mounting
#
# @param devices 
# Array of device paths or names. Must be an array of strings or absolute paths.
#
# @param fs_type The filesystem type to use, e.g., 'zfs'. Defaults to 'zfs'.
#
# @param target The target mount point.
#
# @groups device_config devices, fs_type, target
#
define common::device::filesystem (
  Array[Variant[Stdlib::Absolutepath, Eit_types::SimpleString]] $devices,
  Enum['zfs'] $fs_type,
  Stdlib::Absolutepath $target,
) {

  # We don't actually need to do anything here; zfs filesystems are handled in
  # ::common::device::encrypted_disk

  case $fs_type {
    zfs: {
      $_pool_service = "${name}-pool.service"

      common::services::systemd { $_pool_service:
        unit    => {
          'After'    => $devices.map |$_device_name| {
            "disk@${_device_name}.service"
          }.join(' '),
          'Requires' => $devices.map |$_device_name| {
            "disk@${_device_name}.service"
          }.join(' '),
            'PartOf' => "${name}.mount",
        },
        service => {
          'ExecStart'       => "/usr/sbin/zpool import ${name}",
          'ExecStop'        => "/usr/sbin/zpool export ${name}",
          'RemainAfterExit' => 'yes',
        }
      }

      common::services::systemd { "${name}.mount":
        ensure => 'running',
        unit   => {
          'Description' => "Mount ${fs_type} volume ${name}",
          'Requires'    => $_pool_service,
          'After'       => $_pool_service,
        },
        mount  => {
          'Where'   => $target,
          'What'    => $name,
          'Type'    => $fs_type,
          'Options' => 'defaults,atime,relatime,dev,exec,rw,suid,nomand,zfsutil',
        },
      }
    }
    default: {
      fail("unsupported fs type ${fs_type}")
    }
  }

# [Unit]
# SourcePath=/etc/zfs/zfs-list.cache/rpool
# Documentation=man:zfs-mount-generator(8)

# Before=zfs-mount.service local-fs.target
# After= zfs-load-key-rpool.service
# Wants=
# BindsTo=zfs-load-key-rpool.service



# [Mount]
# Where=/var/log
# What=rpool/ROOT/ubuntu_cysp4m/var/log
# Type=zfs
# Options=defaults,atime,relatime,dev,exec,rw,suid,nomand,zfsutil


}
