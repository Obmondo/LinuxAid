# == Class: vagrant::user
#
# Creates vagrant user and group with authorized insecure key and sudo access.
# Only *nix systems are supported.
#
# === Parameters
#
# [*ensure*]
#   Ensurable
#
# [*user_name*]
#   Vagrant user name
#
# [*group_name*]
#   Vagrant group name
#
# [*sudo_ensure*]
#   Ensurable for sudo access. It will follow the ensure parameter if it was set to absent
#
# === Examples
#
# # Install latest version
# include vagrant::user
#
# === Copyright
#
# Copyright 2015 North Development AB
#

class vagrant::user (
  $ensure          = present,
  $user_name       = vagrant,
  $group_name      = vagrant,
  $sudo_ensure     = present,
  $authorized_keys = undef,
) {

  $user_home = "/home/${user_name}"

  case $ensure {
    'present': {
      Group[$group_name] {
        before => User[$user_name]
      }
    }
    'absent': {
      User[$user_name] {
        before => Group[$group_name]
      }
    }
    default: { fail('$ensure must be present or absent') }
  }

  user {$user_name:
    ensure     => $ensure,
    home       => $user_home,
    managehome => true,
    password   => '$1$ZFFPNB/o$t77BItx.7yFE.CODbOpb6/',
    comment    => 'Vagrant User',
    shell      => '/bin/bash',
    groups     => [$group_name, 'wheel'],
  }

  group {$group_name:
    ensure  => $ensure,
    members => $user_name,
  }

  File {
    owner   => $user_name,
    group   => $group_name,
    require => [User[$user_name], Group[$group_name]],
  }

  $dir_ensure = $ensure ? {
    'present' => directory,
    default => absent
  }

  $authorized_keys_content = $authorized_keys ? {
    undef   => get_insecure_authorized_key(),
    default => $authorized_keys
  }

  file {"${user_home}/.ssh":
    ensure => $dir_ensure,
  }

  file {"${user_home}/.ssh/authorized_keys":
    ensure  => $ensure,
    content => $authorized_keys_content,
    replace => false,
  }

  $real_sudo_ensure = $ensure ? {
    'absent'  => absent,
    default => $sudo_ensure
  }

  file {'/etc/sudoers.d/vagrant':
    ensure  => $real_sudo_ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0440',
    content => template("${module_name}/user/sudo.erb"),
  }
}
