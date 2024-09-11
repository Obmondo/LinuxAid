# == Class: phpmyadmin
#
# This is the installer/main class for phpmyadmin. This allows you to do a very basic install of phpmyadmin.
# Additionally the class will generate a basic apache config file with some basic permissions for access
#
# === Parameters
# [*enabled*]
#   Default to true. This sets the package as installed or uninstalled and affects the config as well.
# [*manage_apache*]
#   If true, will attempt to install the apache module (default: true)
# [*ip_access_ranges*]
#   True to what it sounds like, this sets the ip ranges which are allowed to access phpmyadmin.
#   These IP ranges can be either a single range or an array. Should be in dotted quad or ipv6
#   notation (ex: 192.168.1.0/255.255.255.0, 192.168.1.10, 2012:db8:1234:ffff:ffff:ffff:ffff:ffff, etc.)
#
# === Examples
#
#  class { phpmyadmin:
#    enabled          => true,
#    ip_access_ranges => [ '192.168.1.0/255.255.255.0', '10.30.1.1' ],
#  }
#
# === Authors
#
# Justice London <jlondon@syrussystems.com>
#
# === Copyright
#
# Copyright 2013 Justice London, unless otherwise noted.
#
class phpmyadmin (
  $enabled               = true,
  $manage_apache         = true,
  $ip_access_ranges      = ["${::network_eth0}/${::netmask_eth0}"],
  $preseed_package       = $::phpmyadmin::params::preseed_package,
  $package_name          = $::phpmyadmin::params::package_name,
  $apache_default_config = $::phpmyadmin::params::apache_default_config,
  $apache_name           = $::phpmyadmin::params::apache_name,
) inherits ::phpmyadmin::params {

  #Variable validations
  validate_bool($enabled)
  validate_bool($manage_apache)
  validate_array($ip_access_ranges)
  validate_bool($preseed_package)
  validate_string($package_name)
  validate_string($apache_default_config)
  validate_string($apache_name)

  #Hacky, but if we want to not break with an already included apache... override mpm
  #If someone knows how to actually get out-of-scope variables to properly inherit
  #let me know.
  if $manage_apache == true and !defined(Class['::apache']) {
    class { '::apache':
      mpm_module => 'prefork',
    }
    include ::apache::mod::php

    #Default/basic apache config file for phpMyAdmin
    file { $apache_default_config:
      ensure  => $state_select,
      content => template('phpmyadmin/phpMyAdmin.conf.erb'),
      require => Package[$package_name],
      notify  => Service[$apache_name],
    }
  }

  $enabledt = str2bool($enabled)
  #Define present/absent for enabled state (true/false)
  $state_select = $enabledt ? {
    true    => 'present',
    default => 'absent',
  }

  if $preseed_package {
    phpmyadmin::debconf { 'reconfigure-webserver':
      selection  => 'phpmyadmin/reconfigure-webserver',
      value_type => 'multiselect',
      value      => 'apache2',
      before     => Package[$package_name],
    }
  }

  #Install or remove package based on enable status
  ensure_packages([$package_name], { ensure => $state_select })
}
