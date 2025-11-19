# @summary Class for setting up obmondo-admin account configurations
#
# @param manager_pubkeys Array of SSH public keys for obmondo admin user.
#
# @param sre_pubkeys Array of SSH public keys for obmondo admin user.
#
# @param allow_sre Boolean value to allow SRE to login. Defaults to true.
#
# @param noop_value Boolean value to control noop execution mode. Defaults to false.
#
class common::setup::obmondo_admin (
  Optional[Array[String]] $manager_pubkeys = [],
  Optional[Array[String]] $sre_pubkeys     = [],
  Boolean                 $allow_sre       = true,
  Boolean                 $noop_value      = false,
) {
  contain common::setup

  $_enable = $::obmondo_monitor
  $__opt_dir = $common::setup::__opt_dir
  $_home = "${__opt_dir}/home"
  $_home_admin = "${_home}/obmondo-admin"
  $_home_admin_ssh = "${_home_admin}/.ssh"

  file {
    default:
      ensure => ensure_dir($_enable),
      noop   => $noop_value,
    ;

    $_home_admin:
      owner   => 'obmondo-admin',
      group   => 'obmondo',
      mode    => '0755',
      require => User['obmondo-admin'],
    ;

    $_home_admin_ssh:
      ensure  => directory,
      owner   => 'obmondo-admin',
      group   => 'obmondo',
      mode    => '0700',
      require => File[$_home_admin],
    ;

    [
      '/etc/ssl/private/',
      '/etc/ssl/private/letsencrypt',
    ]:
      mode  => '0700',
      owner => 'root',
      group => 'root',
    ;
  }

  user { 'obmondo-admin':
    ensure         => present,
    comment        => 'Obmondo adminstration user',
    forcelocal     => true,
    gid            => 'obmondo',
    system         => true,
    shell          => '/bin/bash',
    managehome     => true,
    home           => '/opt/obmondo/home/obmondo-admin',
    password       => '!',
    purge_ssh_keys => true,
    noop           => $noop_value,
    require        => Group['obmondo'],
  }

  profile::system::sudoers::conf { 'obmondo-admin':
    content    => 'obmondo-admin ALL=(ALL) NOPASSWD: ALL',
    noop_value => $noop_value,
  }

  $all_pubkeys = ($allow_sre and $_enable) ? {
    true    => $manager_pubkeys + $sre_pubkeys,
    default => $manager_pubkeys,
  }

  $all_pubkeys.each |$key| {
    $_key = functions::split_ssh_key($key)
    ssh_authorized_key { "obmondo-admin ssh key ${_key['comment']}":
      ensure  => ensure_present($_enable),
      type    => $_key['type'],
      key     => $_key['key'],
      user    => 'obmondo-admin',
      noop    => $noop_value,
      require => [
        User['obmondo-admin'],
        File[$_home_admin, $_home_admin_ssh],
      ],
    }
  }
}
