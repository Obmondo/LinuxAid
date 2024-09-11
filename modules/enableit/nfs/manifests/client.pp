# == Class: nfs::client
#
# Installs the NFS client software, allowing the mount resource type to mount
# NFS exports.
#
# === Parameters
#
# [*ensure*]
#   Corresponds to the ensure parameter of the Package resource type.
#
# === Variables
#
# This module requires no variables.
#
# === Examples
#
#  class { 'nfs::client':
#    ensure => installed,
#  }
#
# === Authors
#
# Joseph Beard <joseph@josephbeard.net>
#
# === Copyright
#
# Copyright 2014 Joseph Beard
#
class nfs::client (
  Array[String] $packages,
  Enum['installed', 'absent'] $ensure = installed,
) inherits ::nfs {

  package { $packages:
    ensure => $ensure,
  }
}
