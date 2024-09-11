# == Class: gerrit::install
#
# This class does the base installation of Gerrit any any required
# supporting applications. This class should not be called directly but
# only via Class['gerrit']
#
# === Parameters
#
# This class accepts no parameters directly
#
# === Variables
#
# This class accepts no variables directly
#
# === Authors
#
# Andrew Grimberg <agrimberg@linuxfoundation.org>
#
# === Copyright
#
# Copyright 2014 Andrew Grimberg
#
class gerrit::install {
  $options = $gerrit::options

  # include the java class if we are to install java
  if ($gerrit::install_java) {
    include '::java'
  }

  # include the git class if we are to install git
  if ($gerrit::install_git) {
    include '::git'
  }

  # install gitweb if desired
  if ($gerrit::install_gitweb) {
    package { 'gitweb':
      ensure => installed,
    }
  }

  # manage the user
  $gerrit_user = $options['container']['user']
  validate_string($gerrit_user)

  user { $gerrit_user:
    ensure     => present,
    comment    => 'Gerrit Service User',
    home       => $gerrit::gerrit_home,
    managehome => true,
    shell      => '/bin/bash',
    system     => true,
  }

  # setup the installation directory structure and git storage
  $gerrit_home = $gerrit::gerrit_home
  $gitpath = $options['gerrit']['basePath']
  validate_absolute_path($gitpath)

  file { [
      "${gerrit_home}/bin",
      "${gerrit_home}/etc",
      "${gerrit_home}/lib",
      "${gerrit_home}/logs",
      "${gerrit_home}/plugins",
      "${gerrit_home}/static",
      "${gerrit_home}/tmp",
      $gitpath,
    ]:
    ensure  => directory,
    owner   => $gerrit_user,
    group   => $gerrit_user,
    require => User[$gerrit_user],
  }

  # download gerrit
  $gerrit_version = $gerrit::gerrit_version
  $download_location = $gerrit::download_location

  exec { "download gerrit ${gerrit_version}":
    cwd     => "${gerrit_home}/bin",
    path    => [ '/usr/bin', '/usr/sbin' ],
    command => "curl -s -O ${download_location}/gerrit-${gerrit_version}.war",
    creates => "${gerrit_home}/bin/gerrit-${gerrit_version}.war",
    user    => $gerrit_user,
    group   => $gerrit_user,
  }
}
