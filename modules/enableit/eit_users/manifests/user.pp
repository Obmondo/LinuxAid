# User definations
define eit_users::user (
  Enum['present', 'absent']           $ensure              = 'present',
  Optional[Stdlib::Absolutepath]      $home                = undef,
  Stdlib::Absolutepath                $shell               = '/bin/bash',
  Optional[Eit_types::User]           $uid                 = undef,
  Optional[Eit_types::Group]          $gid                 = undef,
  Optional[String]                    $password_hash       = undef,
  Optional[Pattern[/^\d{4}-\d{2}-\d{2}$/]] $expiry         = undef,
  String                              $realname            = $name,
  Optional[Boolean]                   $system              = undef,
  Variant[Boolean, Enum['nopasswd']]  $sudoroot            = false,
  Boolean                             $sudo_nopasswd       = false,
  Array[Eit_types::Group]             $groups              = [],
  Boolean                             $purge_ssh_keys      = true,
  Array[Eit_types::Ssh_pubkey]        $ssh_authorized_keys = [],
  Optional[Boolean]                   $noop_value          = undef,
) {

  $_managehome = $ensure ? {
    'present' => true,
    default   => false,
  }

  # Make sure we don't try to set the homedir of root to `/home/root`, unless
  # the $home parameter is set
  $_homedir = pick($home, $name ? {
    'root' => '/root',
    default => "/home/${name}",
  })

  $_purge_ssh_keys = $ensure ? {
    'present' => $purge_ssh_keys,
    default   => false,
  }

  user { $title:
    ensure         => $ensure,
    noop           => $noop_value,
    uid            => $uid,
    gid            => $gid,
    groups         => $groups,
    shell          => $shell,
    home           => $_homedir,
    comment        => $realname,
    password       => $password_hash,
    expiry         => $expiry,
    managehome     => $_managehome,
    system         => $system,
    # puppet will complain if we try to purge ssh keys for missing users
    purge_ssh_keys => $_purge_ssh_keys,
    require        => if $gid {
      Group[$gid]
    },
  }

  if $sudoroot {
    $_content = if $sudo_nopasswd or $sudoroot == 'nopasswd' {
      "${name} ALL=(ALL) NOPASSWD: ALL"
    } else {
      "${name} ALL=(ALL) ALL"
    }

    profile::system::sudoers::conf { $name:
      ensure     => $ensure,
      content    => $_content,
      noop_value => $noop_value,
    }
  }

  $ssh_authorized_keys.each |$x| {
    $sshkey = $x ? {
      String  => $x,
      default => $x['key'],
    }

    $options = $x ? {
      String  => [],
      default => $x['options'],
    }

    $sshkey_match = functions::split_ssh_key($sshkey)

    ssh_authorized_key { "${name}_${sshkey_match['comment']}":
      ensure  => $ensure,
      noop    => $noop_value,
      type    => $sshkey_match['type'],
      key     => $sshkey_match['key'],
      user    => $title,
      options => $options,
      require => User[$title],
    }
  }
}
