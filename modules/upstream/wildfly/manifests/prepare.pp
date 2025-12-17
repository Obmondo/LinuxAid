# Manages Wildfly requirements (user, group, dirs and packages)
class wildfly::prepare {
  if $wildfly::manage_user {
    group { $wildfly::group :
      ensure => present,
      gid    => $wildfly::gid,
    }

    user { $wildfly::user :
      ensure     => present,
      uid        => $wildfly::uid,
      gid        => $wildfly::gid,
      groups     => $wildfly::group,
      shell      => '/bin/bash',
      home       => $wildfly::user_home,
      comment    => "${wildfly::user} user created by Puppet",
      managehome => true,
      require    => Group[$wildfly::group],
    }
  }

  unless $wildfly::package_name {
    file { $wildfly::dirname :
      ensure  => directory,
      owner   => $wildfly::user,
      group   => $wildfly::group,
      mode    => '0755',
      require => User[$wildfly::user],
    }
  }

  if $wildfly::package_ensure {
    $libaiopackage  = $facts['os']['family'] ? {
      'RedHat' => 'libaio',
      'Debian' => 'libaio1',
      default  => 'libaio',
    }

    ensure_packages({ $libaiopackage => { 'ensure' => $wildfly::package_ensure } })
  }
}
