#
# This class can be used to configure the drbd service.
#
# It has been influenced by the camptocamp module as well as
# by an example created by Rackspace's cloudbuilders
#
# @param service_enable
#  if service should be enabled
# @param service_ensure
#  what we ensure for the service
# @param package_name
#  name of the drbd package to install
# @param global_options
#  array of global options for /etc/drbd.d/global_common.conf
# @param common_options
#  array of common options for /etc/drbd.d/global_common.conf
# @param common_suboptions
#  hash of suboptions for /etc/drbd.d/global_common.conf
#
class drbd (
  Boolean                                 $service_enable    = true,
  Enum['running', 'stopped', 'unmanaged'] $service_ensure    = running,
  String                                  $package_name      = 'drbd8-utils',
  Array[String[1]]                        $global_options    = ['usage-count no'],
  Array[String[1]]                        $common_options    = ['protocol C'],
  Drbd::Common_suboptions                 $common_suboptions = {},
) {
  include drbd::service

  package { 'drbd':
    ensure => present,
    name   => $package_name,
  }

  # ensure that the kernel module is loaded
  exec { 'modprobe drbd':
    path   => ['/bin/', '/sbin/'],
    unless => 'grep -qe \'^drbd \' /proc/modules',
  }

  File {
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    require => Package['drbd'],
    notify  => Class['drbd::service'],
  }

  file { '/drbd':
    ensure => directory,
  }

  # this file just includes other files
  file { '/etc/drbd.conf':
    source => 'puppet:///modules/drbd/drbd.conf',
  }

  file { '/etc/drbd.d/global_common.conf':
    content => template('drbd/global_common.conf.erb'),
  }

  # only allow files managed by puppet in this directory.
  file { '/etc/drbd.d':
    ensure  => directory,
    mode    => '0644',
    purge   => true,
    recurse => true,
    force   => true,
    require => Package['drbd'],
  }
}
