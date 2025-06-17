# Setup Class
class common::setup (
  Array[String]        $obmondo_admin_user_pubkeys,

  Stdlib::Absolutepath $__conf_dir = '/etc/obmondo',
  Stdlib::Absolutepath $__opt_dir  = '/opt/obmondo',
  Stdlib::Absolutepath $__bin_dir  = '/opt/obmondo/bin',
  Boolean              $noop_value = false,
  Boolean              $jumphost = false,
) {
  include common::system::authentication::sudo
  contain ::common::virtualization
  if $jumphost {
    contain common::setup::jumphost
  }
  # create obmondo dirs and copy libraries
  $_home = "${__opt_dir}/home"
  $_home_admin = "${_home}/obmondo-admin"
  $_home_admin_ssh = "${_home_admin}/.ssh"

  file {
    default:
      ensure => directory,
      noop   => $noop_value,
      ;

    [$__conf_dir, $__opt_dir, $_home]:
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
      "${__opt_dir}/share",
      "${__opt_dir}/etc",
    ]:
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

  # Create Obmondo User and Group
  group { 'obmondo':
    ensure => present,
    system => true,
    noop   => $noop_value,
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

  $obmondo_admin_user_pubkeys.each |$key| {
    $_key = functions::split_ssh_key($key)
    ssh_authorized_key { "obmondo-admin ssh key ${_key['comment']}":
      ensure  => present,
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
