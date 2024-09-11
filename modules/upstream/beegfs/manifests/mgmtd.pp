# Class: beegfs::mgmtd
#
# This module manages BeeGFS mgmtd
#
class beegfs::mgmtd (
  Boolean              $enable                        = true,
  Stdlib::AbsolutePath $directory                     = '/srv/beegfs/mgmtd',
  Boolean              $allow_first_run_init          = true,
  Integer[0,default]   $client_auto_remove_mins       = $beegfs::client_auto_remove_mins,
  Beegfs::ByteAmount   $meta_space_low_limit          = $beegfs::meta_space_low_limit,
  Beegfs::ByteAmount   $meta_space_emergency_limit    = $beegfs::meta_space_emergency_limit,
  Beegfs::ByteAmount   $storage_space_low_limit       = $beegfs::storage_space_low_limit,
  Beegfs::ByteAmount   $storage_space_emergency_limit = $beegfs::storage_space_emergency_limit,
                       $version                       = $beegfs::version,
  Beegfs::LogDir       $log_dir                       = $beegfs::log_dir,
  Beegfs::LogType      $log_type                      = $beegfs::log_type,
  Beegfs::LogLevel     $log_level                     = 2,
  String               $user                          = $beegfs::user,
  String               $group                         = $beegfs::group,
                       $package_ensure                = $beegfs::package_ensure,
  Array[String]        $interfaces                    = ['eth0'],
  Stdlib::AbsolutePath $interfaces_file               = '/etc/beegfs/interfaces.mgmtd',
  Beegfs::Release      $release                       = $beegfs::release,
  Boolean              $enable_quota                  = $beegfs::enable_quota,
  Boolean              $allow_new_servers             = $beegfs::allow_new_servers,
  Boolean              $allow_new_targets             = $beegfs::allow_new_targets,
  Stdlib::Port         $mgmtd_tcp_port                = $beegfs::mgmtd_tcp_port,
  Stdlib::Port         $mgmtd_udp_port                = $beegfs::mgmtd_udp_port,
) inherits ::beegfs {

  require ::beegfs
  require ::beegfs::install

  $_release_major = beegfs::release_to_major($release)

  package { 'beegfs-mgmtd':
    ensure => $package_ensure,
  }

  # mgmtd main directory
  file { $directory:
    ensure  => directory,
    owner   => $user,
    group   => $group,
    recurse => true,
  }

  file { $interfaces_file:
    ensure  => present,
    owner   => $user,
    group   => $group,
    mode    => '0644',
    content => template('beegfs/interfaces.erb'),
  }

  file { '/etc/beegfs/beegfs-mgmtd.conf':
    ensure  => present,
    owner   => $user,
    group   => $group,
    content => template("beegfs/${_release_major}/beegfs-mgmtd.conf.erb"),
    require => [
      Package['beegfs-mgmtd'],
      File[$interfaces_file],
    ],
  }

  service { 'beegfs-mgmtd':
    ensure     => running,
    enable     => $enable,
    hasstatus  => true,
    hasrestart => true,
    require    => [
      Package['beegfs-mgmtd'],
      File[$interfaces_file],
    ],
    subscribe  => [
      File['/etc/beegfs/beegfs-mgmtd.conf'],
      File[$interfaces_file],
    ],
  }
}
