define drbd::resource::up (
  $disk,
  $ha_primary,
  $initial_setup,
  $fs_type,
  $mkfs_opts,
  $device,
  $mountpoint,
  $automount,
) {
  # create metadata on device, except if resource seems already initalized.
  # drbd is very tenacious about asking for aproval if there is data on the
  # volume already.
  exec { "initialize DRBD metadata for ${name}":
    command => "yes yes | drbdadm create-md ${name}",
    onlyif  => "test -e ${disk}",
    unless  => "drbdadm dump-md ${name} || (drbdadm cstate ${name} | egrep -q '^(Sync|Connected|WFConnection|StandAlone|Verify)')",
    before  => Service['drbd'],
    require => [
      Exec['modprobe drbd'],
      Concat["/etc/drbd.d/${name}.res"],
      ],
    notify  => Service['drbd'],
  }

  exec { "enable DRBD resource ${name}":
    command => "drbdadm up ${name}",
    onlyif  => "drbdadm dstate ${name} | egrep -q '^(Diskless/|Unconfigured|Consistent)'",
    before  => Service['drbd'],
    require => [
      Exec["initialize DRBD metadata for ${name}"],
      Exec['modprobe drbd']
      ],
    notify  => Service['drbd'],
  }


  # these resources should only be applied if we are configuring the
  # primary node in our HA setup
  if $ha_primary {
    # these things should only be done on the primary during initial setup
    if $initial_setup {
      exec { "drbd_make_primary_${name}":
        command => "drbdadm -- --overwrite-data-of-peer primary ${name}",
        unless  => "drbdadm role ${name} | egrep '^Primary'",
        onlyif  => "drbdadm dstate ${name} | egrep '^Inconsistent'",
        notify  => Exec["drbd_format_volume_${name}"],
        before  => Exec["drbd_make_primary_again_${name}"],
        require => Service['drbd'],
      }
      $before = $automount ? {
        false   => undef,
        default => Mount[$mountpoint],
      }
      exec { "drbd_format_volume_${name}":
        command     => "mkfs.${fs_type} ${mkfs_opts} ${device}",
        refreshonly => true,
        require     => Exec["drbd_make_primary_${name}"],
        before      => $before,
      }
    }

    exec { "drbd_make_primary_again_${name}":
      command => "drbdadm primary ${name}",
      unless  => "drbdadm role ${name} | egrep '^Primary'",
      require => Service['drbd'],
    }

    if $automount {
      # ensure that the device is mounted
      mount { $mountpoint:
        ensure  => mounted,
        atboot  => false,
        device  => $device,
        fstype  => 'auto',
        options => 'defaults,noauto',
        require => [
          Exec["drbd_make_primary_again_${name}"],
          File[$mountpoint],
          Service['drbd']
        ],
      }
    }
  }
}
