# NFS class
class nfs (
  String                         $nobody_username,
  String                         $nobody_groupname,
  String                         $nobody_gecos,
  Optional[Integer[0,default]]   $nobody_uid,
  Optional[Integer[0,default]]   $nobody_gid,
  Optional[Stdlib::Absolutepath] $nobody_shell,
  Optional[Stdlib::Absolutepath] $nobody_home,
) {

  # This module is accessed via the nfs::server and nfs::client classes. Don't
  # purge the nfsnobody group or user
  group { $nobody_groupname:
    ensure => 'present',
    gid    => $nobody_gid,
  }

  user { $nobody_username:
    ensure           => 'present',
    uid              => $nobody_uid,
    gid              => $nobody_gid,
    home             => $nobody_home,
    shell            => $nobody_shell,
    comment          => $nobody_gecos,
    password         => '!!',
    password_max_age => '-1',
    password_min_age => '-1',
    require          => Group[$nobody_groupname],
  }

}
