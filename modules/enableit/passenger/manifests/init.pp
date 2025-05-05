# == Class: passenger
#
# Full description of class passenger here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { 'passenger': }
#
# === Authors
#
# Ashish Jaiswal <ashish@enableit.dk>
#
# === Copyright
#
# Copyright 2015 Ashish Jaiswal, unless otherwise noted.
#
class passenger (
  String                $passenger_name     = 'passenger',
  Integer[4, 5]         $passenger_version  = 5,
  Optional[Enum['gem']] $passenger_provider = undef,
  Enum['apache']        $compile            = 'apache',
  Boolean               $manage_web_server  = false,
) inherits passenger::params {

  # On RedHat/CentOS 7 and Debian, only version 5 is supported
  confine(
    $passenger_version != 5,
    $facts[os][name] == 'RedHat',
    $facts[os][majdistrelease] == 7,
    'Only version 5 is supported.')

  confine(
    $passenger_version != 5,
    $facts[os][name] == 'Debian',
    'Only version 5 is supported.')

  case $passenger_provider {
    undef: {

      #TODO
      # Support passenger_version 3

      case $passenger_version {
        5: {
          # Setup Repository
          class { 'passenger::repo' : notify => Class['passenger::install'] }

          $_passenger_name    = $passenger_name
          $_passenger_version = 'present'

          case $facts['os']['family'] {
            'RedHat' : { stdlib::ensure_packages('mod_passenger') }
            'Debian' : { stdlib::ensure_packages('libapache2-mod-passenger') }
            default  : { fail('Not Supported') }
          }
        }
        4: {
          case $facts['os']['family'] {
            'RedHat': {

              # Setup enableit private repo
              if $facts['os']['release']['major'] == '7' {
                fail('Passenger version 4 is not supported from enableit on Centos7, Please setup using gems or select Passenger version 5')
              }

              $_passenger_name    = 'rubygem-passenger'
              $_passenger_version = 'present'

              # Install passenger apache module
              stdlib::ensure_packages('rubygem-passenger-apache2-module')
            }
            'Debian': {

              # TODO
              fail('Passenger version 4 is not supported on Debian family as of now')
            }
            default  : { fail('Not Supported') }
          }
        }
        default: {
          fail("This ${passenger_version} passenger version is not supported")
        }
      }
      # get mod_passenger location for package installation
      $_passenger_mod_passenger = $passenger::params::mod_passenger
    }
    'gem' : {

      # Present should point to 5.0.20, casue we need version number to build proper passenger.conf for apache or nginx
      case $passenger_version {
        5 : {
          $_passenger_version = '5.0.20'
        }
        4 : {
          $_passenger_version = '4.0.59'
        }
        default  : { fail('Not Supported') }
      }

      # Setup default variables for gem installation
      class { '::passenger::gems' :
        passenger_version => $_passenger_version,
        notify            => Class['passenger::install']
      }

      # Get mod_passenger location for gems from passenger::gems
      $_passenger_mod_passenger = $passenger::gems::mod_passenger
    }
    default : {
      fail("provider '${passenger_provider}' is not supported")
    }
  }

  # Install passenger standalone
  class { 'passenger::install' :
    passenger_name     => $_passenger_name,
    passenger_version  => $_passenger_version,
    passenger_provider => $passenger_provider
  }

  if $passenger_version == 5 or $passenger_provider == 'gem' {
    # Setup passenger with apache or nginx
    class { 'passenger::compile' :
      webserver     => $compile,
      mod_passenger => $_passenger_mod_passenger,
      require       => Class['passenger::install'],
      notify        => Class['passenger::config']
    }
  }

  # Setup the passenger.module file
  class { 'passenger::config' :
    manage_web_server => $manage_web_server,
    require           => Class['passenger::install' ]
  }

  if $manage_web_server {
    # Setup the webserver
    class { 'passenger::service' :
      webserver => $compile,
      require   => Class['passenger::install', 'passenger::config']
    }
  }
}
