# atop
class profile::monitoring::atop (
  Boolean $daemon  = $common::monitoring::atop::daemon,
  Boolean $install = $common::monitoring::atop::install,
) {

  package::install('atop', {
    ensure => ensure_present($install),
    before => [
      Cron['atop'],
      if $facts['init_system'] == 'systemd' {
        Systemd::Unit_file['atop.service']
      } else {
        Service['atop']
      },
    ].delete_undef_values,
  })

  if $install {
    # Ensure cron job from package is removed
    file { '/etc/cron.d/atop':
      ensure  => 'absent',
      require => Package['atop'],
    }
  }

  # Install our own cron job in its place
  cron { 'atop':
    ensure  => ensure_present($daemon),
    user    => 'root',
    command => 'systemctl try-restart atop',
    hour    => 0,
    minute  => 0,
  }

  # For some reason atop seems to always come back on Ubuntu systems, even
  # when it's disabled, so let's mask it if disabled.
  $_enable = if $daemon {
    {
      'enable' => if $daemon { true } else { 'mask' },
      'active' => $daemon
    }
  } else {
    {}
  }

  if $facts['init_system'] == 'systemd' {
    systemd::unit_file { [
      'atop.service',
      'atopacct.service',
    ]:
      ensure => ensure_present($install),
      *      => $_enable,
    }
  } else {
    service { 'atop':
      ensure => ensure_service($daemon),
    }
  }

}
