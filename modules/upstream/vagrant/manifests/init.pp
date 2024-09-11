# == Class: vagrant
#
# Installs vagrant - https://www.vagrantup.com/downloads.html
#
# === Parameters
#
# [*ensure*]
#   Ensurable
#
# [*version*]
#   The version of the package you want to install. Example: '1.5.4'.
#   If not specified the module will try to get the latest
#   version number from vagrant website.
#
# [*install_from_source*]
#   Boolean if package resource should use defined source variable
#
# [*source*]
#   Package source URL
#
# [*provider*]
#   Package resource provider to be used
#
# === Examples
#
# # Install latest version
# include vagrant
#
# # Install version 1.6.3
# class { 'vagrant':
#   version => '1.6.3'
# }
#
# === Copyright
#
# Copyright 2015 North Development AB
#

class vagrant (
  $version                = $vagrant::params::version,
  $ensure                 = $vagrant::params::ensure,
  $install_from_source    = $vagrant::params::install_from_source,
  $source                 = $vagrant::params::source,
  $provider               = $vagrant::params::provider,
  $path                   = $vagrant::params::path
) inherits vagrant::params {

  validate_bool($install_from_source)

  if $install_from_source {
    vagrant::package {"vagrant-${version}":
      ensure   => $ensure,
      version  => $version,
      provider => $provider,
      path     => $path,
      source   => $source
    }
  } else {
    package {'vagrant':
      ensure   => $ensure,
      provider => $provider,
      version  => $version
    }
  }
}
