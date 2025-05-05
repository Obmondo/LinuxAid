# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include thinlinc::install
class thinlinc::install (
  Array[String]       $packages,
  Array[String]       $thinlinc_dependencies,
  Array[String]       $service_dependencies,
  Hash[String,String] $package_name_map = {},
  Array[String]       $profile_order    = $::thinlinc::profile_order,
)
inherits ::thinlinc {

  stdlib::ensure_packages($thinlinc_dependencies, {
    ensure => present,
    before => Package[$packages],
  })

  $service_dependencies.each |$_package| {
    unless defined(Package[$_package]) {
      package { $_package:
        ensure => present,
        before => Package[$packages],
      }
    }
  }

  stdlib::ensure_packages($packages, {
    ensure  => $::thinlinc::version,
  })


  if $::thinlinc::profile_install {
    $_profile_package_names = $profile_order.map |$_profile| {
      pick(
        $package_name_map.dig($_profile),
        $_profile,
      )
    }

    $_profile_groups = $_profile_package_names.filter |$_package| {
      $_package[0] == '@'
    }

    if $_profile_groups.size {
      yum::group { $_profile_groups:
        ensure => 'installed',
      }
    }

    $_profile_packages = $_profile_package_names - $_profile_groups

    package { $_profile_packages:
      ensure => 'installed',
    }
  }

  if $facts['os']['family'] == 'RedHat' {
    file { '/usr/local/bin/python-thinlinc':
      ensure => 'link',
      target => '/usr/bin/python2.7',
    }
  }

  # This file is normally symlinked from tl-setup.py
  file { '/usr/bin/thinlinc-login':
    ensure => 'link',
    target => '/opt/thinlinc/libexec/thinlinc-login',
  }

  # This file is normally symlinked from tl-setup.py
  file { '/etc/pam.d/thinlinc':
    ensure => 'link',
    target => '/etc/pam.d/sshd',
  }

  file { '/opt/thinlinc/etc/xstartup.d':
    ensure  => 'directory',
    source  => "puppet:///modules/${module_name}/etc/xstartup.d",
    recurse => true,
  }

  # logging
  $_log_dirs = [
    if $thinlinc::log_to_file           { $thinlinc::log_dir },
    if $thinlinc::vsmserver_log_to_file { $thinlinc::vsmserver_log_dir },
    if $thinlinc::vsmagent_log_to_file  { $thinlinc::vsmagent_log_dir },
    if $thinlinc::webaccess_log_to_file { $thinlinc::webaccess_log_dir },
  ].delete_undef_values.sort.unique

  file { $_log_dirs :
    ensure => directory,
  }

}
