# Auth Ldap profile Class
class profile::system::authentication::ldap_auth_daemon (
  Boolean         $ensure      = true,
  Eit_types::Host $listen_host = 'localhost',
  Stdlib::Port    $listen_port = 8888,
) {


  file { '/opt/ldap_auth_daemon':
    ensure => if $ensure { 'directory' } else { 'absent' },
    source => 'puppet:///modules/profile/auth/ldap_auth_daemon/daemon',
  }

  file { '/opt/ldap_auth_daemon/server.py':
    mode   => '0755',
    source => 'puppet:///modules/profile/auth/ldap_auth_daemon/daemon/server.py',
  }

  file { '/etc/systemd/system/ldap_auth_daemon.service':
    ensure => if $ensure { 'present' } else { 'absent' },
    source => 'puppet:///modules/profile/auth/ldap_auth_daemon/ldap_auth_daemon.service',
  }

  package { 'python-ldap':
    ensure => if $ensure { installed } else { absent },
    before => Service['ldap_auth_daemon'],
  }

  service { 'ldap_auth_daemon':
    ensure => $ensure,
    enable => $ensure,
  }

}
