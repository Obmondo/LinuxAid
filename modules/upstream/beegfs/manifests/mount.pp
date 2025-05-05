# Define: beegfs::mount
#
# Manages beegfs mounts
#
# @param cfg
# @param mnt
# @param user
# @param group
# @param mounts_cfg
#
define beegfs::mount (
  String               $cfg,
  String               $mnt,
  String               $user       = $beegfs::user,
  String               $group      = $beegfs::group,
  Stdlib::AbsolutePath $mounts_cfg = '/etc/beegfs/beegfs-mounts.conf',
) {
  file { $mnt:
    ensure => directory,
    owner  => $user,
    group  => $group,
    mode   => '0644',
  }

  concat::fragment { $mnt:
    target  => $mounts_cfg,
    content => "${mnt} ${cfg}",
    require => File[$mnt],
  }
}
