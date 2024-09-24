# @summary Manage service resources for postfix
#
# @api private
#
class postfix::service {
  assert_private()

  $manage_aliases = $postfix::manage_aliases

  exec { 'restart postfix after packages install':
    command     => regsubst($postfix::params::restart_cmd, 'reload', 'restart'),
    refreshonly => true,
    subscribe   => Package['postfix'],
    require     => Class['postfix::files'],
  }
  service { 'postfix':
    ensure    => $postfix::service_ensure,
    enable    => $postfix::service_enabled,
    hasstatus => true,
    restart   => $postfix::params::restart_cmd,
  }
  # Aliases
  if $manage_aliases {
    exec { 'newaliases':
      command     => 'newaliases',
      path        => $facts['path'],
      refreshonly => true,
      subscribe   => File['/etc/aliases'],
      require     => Service['postfix'],
    }
  }
  if $facts['os']['family'] == 'RedHat' {
    alternatives { 'mta':
      path    => '/usr/sbin/sendmail.postfix',
      require => Service['postfix'],
    }
  }
}
