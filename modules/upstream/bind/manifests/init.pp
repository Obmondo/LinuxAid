# Class: bind
#
# Install and enable an ISC BIND server.
#
# Parameters:
#  $chroot:
#   Enable chroot for the server. Default: false
#  $packagenameprefix:
#   Package prefix name. Default: 'bind' or 'bind9' depending on the OS
#
# Sample Usage :
#  include bind
#  class { 'bind':
#    chroot            => true,
#    packagenameprefix => 'bind97',
#  }
#
class bind (
  $chroot            = false,
  $service_reload    = true,
  $servicename       = $::bind::params::servicename,
  $packagenameprefix = $::bind::params::packagenameprefix,
  $binduser          = $::bind::params::binduser,
  $bindgroup         = $::bind::params::bindgroup,
) inherits ::bind::params {

  # Chroot differences
  if $chroot == true {
    $packagenamesuffix = '-chroot'
    # Different service name with chroot on RHEL7+)
    if $::osfamily == 'RedHat' and
        versioncmp($::operatingsystemrelease, '7') >= 0 {
      $servicenamesuffix = '-chroot'
    } else {
      $servicenamesuffix = ''
    }
    $bindlogdir = '/var/named/chroot/var/log/named'
  } else {
    $packagenamesuffix = ''
    $servicenamesuffix = ''
    $bindlogdir = '/var/log/named'
  }

  # Main package and service
  class { '::bind::package':
    packagenameprefix => $packagenameprefix,
    packagenamesuffix => $packagenamesuffix,
  }
  class { '::bind::service':
    servicename    => "${servicename}${servicenamesuffix}",
    service_reload => $service_reload,
  }

  # We want a nice log file which the package doesn't provide a location for
  file { $bindlogdir:
    ensure  => 'directory',
    owner   => $binduser,
    group   => $bindgroup,
    mode    => '0770',
    seltype => 'var_log_t',
    require => Class['::bind::package'],
    before  => Class['::bind::service'],
  }

}
