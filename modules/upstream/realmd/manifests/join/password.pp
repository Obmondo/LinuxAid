# == Class realmd::join::password
#
# This class is called from realmd for
# joining AD using a username and password.
#
class realmd::join::password {
  $_domain             = $realmd::domain
  $_user               = $realmd::domain_join_user
  $_password           = $realmd::domain_join_password
  $_ou                 = $realmd::ou
  $_extra_join_options = $realmd::extra_join_options

  if $realmd::computer_name != undef {
    $_computer_name = $realmd::computer_name
  } else {
    $_computer_name = $facts['networking']['hostname'][0,15]
  }

  if $facts['os']['name'] == 'Ubuntu' {
    $_computer_name_arg  = $facts['os']['distro']['codename'] ? {
      'focal'   => '',
      'jammy'   => '',
      default => ["--computer-name=${_computer_name}"],
    }
  } elsif ($facts['os']['family'] == 'RedHat' and Integer($facts['os']['release']['major']) >= 8) {
    $_computer_name_arg = ''
  }
  else {
    $_computer_name_arg = ["--computer-name=${_computer_name}"]
  }

  if $_ou != undef {
    $_realm_args = [$_domain, '--unattended', "--computer-ou='${_ou}'", "--user=${_user}"]
  } else {
    $_realm_args = [$_domain, '--unattended', "--user=${_user}"]
  }

  $_args = strip(join(concat($_realm_args, $_computer_name_arg, $_extra_join_options), ' '))

  file { '/usr/libexec':
    ensure  => 'directory',
  }

  file { '/usr/libexec/realm_join_with_password':
    ensure  => file,
    owner   => '0',
    group   => '0',
    mode    => '0755',
    content => template('realmd/realm_join_with_password.erb'),
    notify  => Exec['realm_join_with_password'],
  }
  $_command = "/usr/libexec/realm_join_with_password realm join ${_args}"

  exec { 'realm_join_with_password':
    environment => ["AD_JOIN_PASSWORD=${_password}"],
    path        => '/usr/bin:/usr/sbin:/bin',
    command     => $_command,
    unless      => "klist -k /etc/krb5.keytab | grep -i '${_computer_name}@${_domain}'",
  }
}
