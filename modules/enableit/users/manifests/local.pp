# local
define users::local (
  Integer $uid,
  Integer $gid,
  String $realname,
  Array[String] $groups = [],
  String $pass = undef,
  Optional[String] $sshkey = undef,
  Stdlib::Absolutepath $shell = '/bin/bash',
  Stdlib::Absolutepath $home = "/home/${title}",
) {

  $_password = $pass ? {
    ''      => undef,
    default => $pass
  }
  user { $title:
    ensure     => 'present',
    uid        => $uid,
    gid        => $gid,
    groups     => $groups,
    shell      => $shell,
    home       => $home,
    comment    => $realname,
    password   => $_password,
    managehome => true,
  }

  if ( $sshkey != '' ) {
    ssh_authorized_key { $title:
      ensure  => 'present',
      type    => dsa,
      key     => $sshkey,
      user    => $title,
      require => User[$title],
      name    => $title,
    }
  }
}
