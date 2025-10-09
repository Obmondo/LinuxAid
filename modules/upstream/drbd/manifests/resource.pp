# Used to created a resource that replicates data
# between 2 hosts for HA.
#
# @param host1
#   Name of first host. Required unless $cluster is set.
# @param host2
#   Name of second host. Required unless $cluster is set.
# @param ip1
#   Ipaddress of first host. Required unless $cluster or $res1/$res2 is set.
# @param ip2
#   Ipaddress of second host. Required unless $cluster or $res1/$res2 is set.
# @param res1
#   First stacked resource name.
# @param res2
#   Second stacked resource name.
# @param cluster
# @param disk
#   Name of disk to be replicated. Assumes that the
#   name of the disk will be the same on both hosts. Required.
# @param metadisk
#   Name of the metadisk. Allows to use an external metadisk. Assumes
#   that the name of the metadisk will be the same on both hosts. Defaults to internal
#   this parameter is ignored if flexible_metadisk is defined
# @param flexible_metadisk
#   Name of the flexible_metadisk
#   defaults to undef. If defined, the metadisk parameter is superseeded
# @param secret
#   The shared secret used in peer authentication.. False indicates that
#   no secret be required. Optional. Defaults to false.
# @param port
#   Port which drbd will use for replication on both hosts.
#   Optional. Defaults to 7789.
# @param mountpoint
# @param automount
# @param device
# @param owner
# @param group
# @param protocol
#   Protocol to use for drbd. Optional. Defaults to 'C'
#   http://www.drbd.org/users-guide/s-replication-protocols.html
# @param verify_alg
#   Algorithm used for block validation on peers. Optional.
#   Defaults to crc32c. Accepts crc32c, sha1, or md5.
# @param rate
# @param disk_parameters
#   Parameters for disk{} section
# @param net_parameters
# @param handlers_parameters
#   Parameters for handlers{} section
# @param startup_parameters
#   Parameters for startup{} section
# @param manage
#   If the actual drbd resource shoudl be managed.
# @param ha_primary
#   If the resource is being applied on the primary host.
# @param initial_setup
#   If this run is associated with the initial setup. Allows a user
#   to only perform dangerous setup on the initial run.
# @param initialize
#   If the actual drbd resource should be initialized
# @param up
#   If the actual drbd resource should be set 'up' (drbdadmin up)
# @param fs_type
# @param mkfs_opts
#
define drbd::resource (
  $host1                                                      = undef,
  $host2                                                      = undef,
  $ip1                                                        = undef,
  $ip2                                                        = undef,
  $res1                                                       = undef,
  $res2                                                       = undef,
  $cluster                                                    = undef,
  $secret                                                     = false,
  $port                                                       = '7789',
  $device                                                     = '/dev/drbd0',
  $mountpoint                                                 = "/drbd/${name}",
  $automount                                                  = true,
  $owner                                                      = 'root',
  $group                                                      = 'root',
  $protocol                                                   = 'C',
  $verify_alg                                                 = 'crc32c',
  $rate                                                       = false,
  $disk_parameters                                            = false,
  $net_parameters                                             = false,
  Hash[String, Variant[Integer,String]] $handlers_parameters  = {},
  Hash[String, Variant[Integer,String]] $startup_parameters   = {},
  $manage                                                     = true,
  $ha_primary                                                 = false,
  $initial_setup                                              = false,
  Boolean $initialize                                         = true,
  Boolean $up                                                 = true,
  $fs_type                                                    = 'ext4',
  $mkfs_opts                                                  = '',
  $disk                                                       = undef,
  String[1] $metadisk                                         = 'internal',
  Optional[String[1]] $flexible_metadisk                      = undef,
) {
  include drbd

  Exec {
    path      => ['/bin', '/sbin', '/usr/bin'],
    logoutput => 'on_failure',
  }

  File {
    owner => 'root',
    group => 'root',
  }

  file { $mountpoint:
    ensure => directory,
    mode   => '0755',
    owner  => $owner,
    group  => $group,
  }

  concat { "/etc/drbd.d/${name}.res":
    mode    => '0600',
    require => [
      Package['drbd'],
      File['/etc/drbd.d'],
    ],
    notify  => Class['drbd::service'],
  }
  # Template uses:
  # - $name
  # - $protocol
  # - $device
  # - $disk
  # - $metadisk
  # - $secret
  # - $verify_alg
  # - $host1
  # - $host2
  # - $ip1
  # - $ip2
  # - $port
  concat::fragment { "${name} drbd header":
    target  => "/etc/drbd.d/${name}.res",
    content => template('drbd/header.res.erb'),
    order   => '01',
  }
  # Export our fragment for the clustered node
  if $ha_primary and $cluster {
    @@concat::fragment { "${name} ${cluster} primary resource":
      target  => "/etc/drbd.d/${name}.res",
      content => template('drbd/resource.res.erb'),
      order   => '10',
    }
  } elsif $cluster {
    @@concat::fragment { "${name} ${cluster} secondary resource":
      target  => "/etc/drbd.d/${name}.res",
      content => template('drbd/resource.res.erb'),
      order   => '20',
    }
  } elsif $host1 and $ip1 and $host2 and $ip2 {
    concat::fragment { "${name} static primary resource":
      target  => "/etc/drbd.d/${name}.res",
      content => template('drbd/primary-resource.res.erb'),
      order   => '10',
    }
    concat::fragment { "${name} static secondary resource":
      target  => "/etc/drbd.d/${name}.res",
      content => template('drbd/secondary-resource.res.erb'),
      order   => '20',
    }
  } elsif $res1 and $ip1 and $res2 and $ip2 {
    concat::fragment { "${name} static stacked primary resource":
      target  => "/etc/drbd.d/${name}.res",
      content => template('drbd/primary-stacked-resource.res.erb'),
      order   => '10',
    }
    concat::fragment { "${name} static stacked secondary resource":
      target  => "/etc/drbd.d/${name}.res",
      content => template('drbd/secondary-stacked-resource.res.erb'),
      order   => '20',
    }
  } else {
    fail('Must provide either cluster, host1/host2/ip1/ip2 or res1/res2/ip1/ip2 parameters')
  }

  concat::fragment { "${name} drbd footer":
    target  => "/etc/drbd.d/${name}.res",
    content => "}\n",
    order   => '99',
  }

  if $cluster {
    # Import cluster nodes
    Concat::Fragment <<| title == "${name} ${cluster} primary resource" |>>
    Concat::Fragment <<| title == "${name} ${cluster} secondary resource" |>>
  }

  # Due to a bug in puppet, defined() conditionals must be in a defined
  # resource to be evaluated *after* the collector instead of before.
  $_cluster = $cluster ? {
    undef   => 'static',
    default => $cluster,
  }
  drbd::resource::enable { $name:
    manage        => $manage,
    disk          => $disk,
    fs_type       => $fs_type,
    mkfs_opts     => $mkfs_opts,
    device        => $device,
    ha_primary    => $ha_primary,
    initial_setup => $initial_setup,
    initialize    => $initialize,
    up            => $up,
    cluster       => $_cluster,
    mountpoint    => $mountpoint,
    automount     => $automount,
  }
}
