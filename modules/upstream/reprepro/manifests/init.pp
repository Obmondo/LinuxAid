# == Class: reprepro
#
#   Configures reprepro on a server
#
# === Parameters
#
#   - *basedir*: The base directory to house the repository.
#   - *homedir*: The home directory of the reprepro user.
#
# === Example
#
#   class { 'reprepro': }
#
class reprepro (
  $basedir     = $::reprepro::params::basedir,
  $homedir     = $::reprepro::params::homedir,
  $manage_user = true,
  $user_name   = $::reprepro::params::user_name,
  $group_name  = $::reprepro::params::group_name,
) inherits reprepro::params {
  validate_bool($manage_user)

  package { $::reprepro::params::package_name:
    ensure => $::reprepro::params::ensure,
  }

  if $manage_user {
    group { $group_name:
      ensure => present,
      name   => $group_name,
      system => true,
    }

    user { $user_name:
      ensure     => present,
      name       => $user_name,
      home       => $homedir,
      shell      => '/bin/bash',
      comment    => 'Reprepro user',
      gid        => $group_name,
      managehome => true,
      system     => true,
      require    => Group[$group_name],
      notify     => [
        File["${homedir}/.gnupg"],
        File["${homedir}/bin"],
      ],
    }
  }

  if ($basedir != $homedir) {
    file { $basedir:
      ensure  => directory,
      owner   => $user_name,
      group   => $group_name,
      mode    => '0755',
      require => User[$user_name],
    }
  }

  file { "${homedir}/.gnupg":
    ensure  => directory,
    owner   => $user_name,
    group   => $group_name,
    mode    => '0700',
  }

  file { "${homedir}/bin":
    ensure  => directory,
    mode    => '0755',
    owner   => $user_name,
    group   => $group_name,
  }
  ->
  file { "${homedir}/bin/update-distribution.sh":
    ensure  => file,
    mode    => '0755',
    content => template('reprepro/update-distribution.sh.erb'),
    owner   => $user_name,
    group   => $group_name,
  }

}

