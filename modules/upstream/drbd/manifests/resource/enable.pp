define drbd::resource::enable (
  $manage,
  $disk,
  $fs_type,
  $mkfs_opts,
  $device,
  $ha_primary,
  $initial_setup,
  $cluster,
  $mountpoint,
  $automount,
) {
  if defined(Concat::Fragment["${name} ${cluster} primary resource"]) and defined(Concat::Fragment["${name} ${cluster} secondary resource"]) {
    realize(Service['drbd'])
  }

  # XXX Can we convert tho two fragments to an anchor pattern?
  if $manage and defined(Concat::Fragment["${name} ${cluster} primary resource"]) and defined(Concat::Fragment["${name} ${cluster} secondary resource"]) {
    drbd::resource::up { $name:
      disk          => $disk,
      ha_primary    => $ha_primary,
      initial_setup => $initial_setup,
      fs_type       => $fs_type,
      mkfs_opts     => $mkfs_opts,
      device        => $device,
      mountpoint    => $mountpoint,
      automount     => $automount,
    }
  }
}
