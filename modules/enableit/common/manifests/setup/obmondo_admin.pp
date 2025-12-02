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
  Boolean                 $manage          = false,
  Boolean                 $enable          = false,
  Optional[Array[String]] $manager_pubkeys = [],
  Optional[Array[String]] $sre_pubkeys     = [],
  Boolean                 $allow_sre       = true,
  Eit_types::Noop_Value   $noop_value      = undef,
) {
  contain common::setup

  File {
    noop => $noop_value,
  }

  if $manage {
    $_enable = $::obmondo_monitor and $enable #lint:ignore:top_scope_facts
    $__opt_dir = $common::setup::__opt_dir
    $_home = "${__opt_dir}/home"
    $_home_admin = "${_home}/obmondo-admin"
    $_home_admin_ssh = "${_home_admin}/.ssh"

    file {
      default:
        ensure => stdlib::ensure($_enable, 'directory'),
      ;

      $_home_admin:
        owner   => 'obmondo-admin',
        group   => 'obmondo',
        mode    => '0755',
        require => User['obmondo-admin'],
      ;

      $_home_admin_ssh:
        ensure  => stdlib::ensure($_enable, 'directory'),
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
      ensure         => stdlib::ensure($_enable),
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

    sudo::conf { 'obmondo-admin':
      ensure   => stdlib::ensure($_enable),
      content  => 'obmondo-admin ALL=(ALL) NOPASSWD: ALL',
      priority => 10,
      noop     => $noop_value,
    }

    $all_pubkeys = ($allow_sre and $_enable) ? {
      true    => $manager_pubkeys + $sre_pubkeys,
      default => $manager_pubkeys,
    }

    $all_pubkeys.each |$key| {
      $_key = functions::split_ssh_key($key)
      ssh_authorized_key { "obmondo-admin ssh key ${_key['comment']}":
        ensure  => stdlib::ensure($_enable),
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
}
