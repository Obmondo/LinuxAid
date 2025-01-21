#
class profile::system::selinux (
  Boolean            $enable                = $common::system::selinux::enable,
  Boolean            $enforce               = $common::system::selinux::enforce,
  Boolean            $enable_setroubleshoot = $common::system::selinux::enable_setroubleshoot,
  Hash[String, Hash] $fcontext              = $common::system::selinux::fcontext,
) {

  if !lookup('common::security::auditd::enable', Boolean, undef, false) {
    contain ::auditd
  }

  if $facts['os']['family'] == 'RedHat' {
    $_selinux_mode = $enable ? {
      true  => $enforce ? {
        true  => 'enforcing',
        false => 'permissive',
      },
      false => 'disabled',
    }

    class { '::selinux':
      mode           => $_selinux_mode,
      manage_package => $enable,
    }
  }

  Ini_setting {
    ensure            => present,
    path              => '/etc/audisp/plugins.d/sedispatch.conf',
    key_val_separator => ' = ',
    show_diff         => true,
  }

  if $enable {
    $fcontext.each |$key, $options| {
      profile::system::selinux::fcontext { $key:
        * => $options
      }
    }

    package::install([
      'setroubleshoot-server',
      'setroubleshoot-plugins',
      'selinux-policy',
    ])

    ini_setting { 'setroubleshoot active':
      setting => 'active',
      value   => $enable_setroubleshoot.to_yesno,
      require => Package['setroubleshoot-server'],
    }
  } else {

    ini_setting { 'setroubleshoot active':
      setting => 'active',
      value   => $enable_setroubleshoot.to_yesno,
      notify  => Exec['force restart auditd'],
    }

    # auditd disables the refresh and restart commands in the systemd unit file,
    # so we can't use `Service` to do force a restart of auditd in order to
    # disable setroubleshoot
    exec { 'force restart auditd':
      command     => 'service auditd restart',
      path        => [
        '/sbin',
        '/usr/sbin',
      ],
      refreshonly => true,
    }
  }

}
