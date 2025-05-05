# Class: beegfs::mgmtd
#
# This module manages BeeGFS mgmtd
# @param enable
# @param directory
# @param allow_first_run_init
# @param client_auto_remove_mins
# @param meta_space_low_limit
# @param meta_space_emergency_limit
# @param storage_space_low_limit
# @param storage_space_emergency_limit
# @param version
# @param log_dir
# @param log_type
# @param log_level
# @param user
# @param group
# @param package_ensure
# @param interfaces
# @param interfaces_file
# @param networks
# @param networks_file
# @param enable_quota
# @param allow_new_servers
# @param allow_new_targets
# @param mgmtd_tcp_port
# @param mgmtd_udp_port
# @param conn_auth_file
#
class beegfs::mgmtd (
  Boolean                        $enable                        = true,
  Stdlib::AbsolutePath           $directory                     = '/srv/beegfs/mgmtd',
  Boolean                        $allow_first_run_init          = true,
  Integer[0,default]             $client_auto_remove_mins       = $beegfs::client_auto_remove_mins,
  Beegfs::ByteAmount             $meta_space_low_limit          = $beegfs::meta_space_low_limit,
  Beegfs::ByteAmount             $meta_space_emergency_limit    = $beegfs::meta_space_emergency_limit,
  Beegfs::ByteAmount             $storage_space_low_limit       = $beegfs::storage_space_low_limit,
  Beegfs::ByteAmount             $storage_space_emergency_limit = $beegfs::storage_space_emergency_limit,
  Optional[String]               $version                       = $beegfs::version,
  Beegfs::LogDir                 $log_dir                       = $beegfs::log_dir,
  Beegfs::LogType                $log_type                      = $beegfs::log_type,
  Beegfs::LogLevel               $log_level                     = 2,
  String                         $user                          = $beegfs::user,
  String                         $group                         = $beegfs::group,
  String                         $package_ensure                = $beegfs::package_ensure,
  Array[String]                  $interfaces                    = ['eth0'],
  Stdlib::AbsolutePath           $interfaces_file               = '/etc/beegfs/interfaces.mgmtd',
  Optional[Array[String]]        $networks                      = undef,
  Stdlib::AbsolutePath           $networks_file                 = '/etc/beegfs/networks.mgmtd',
  Boolean                        $enable_quota                  = $beegfs::enable_quota,
  Boolean                        $allow_new_servers             = $beegfs::allow_new_servers,
  Boolean                        $allow_new_targets             = $beegfs::allow_new_targets,
  Stdlib::Port                   $mgmtd_tcp_port                = $beegfs::mgmtd_tcp_port,
  Stdlib::Port                   $mgmtd_udp_port                = $beegfs::mgmtd_udp_port,
  Optional[Stdlib::AbsolutePath] $conn_auth_file                = $beegfs::conn_auth_file,
) inherits beegfs {
  $_release_major = beegfs::release_to_major($beegfs::release)

  package { 'beegfs-mgmtd':
    ensure  => $package_ensure,
    require => Class['beegfs::install'],
  }

  # mgmtd main directory
  file { $directory:
    ensure  => directory,
    owner   => $user,
    group   => $group,
    recurse => true,
  }

  file { $interfaces_file:
    ensure  => file,
    owner   => $user,
    group   => $group,
    mode    => '0644',
    content => template('beegfs/interfaces.erb'),
    require => Package['beegfs-mgmtd'],
  }

  $network_ensure = $networks ? {
    undef => absent,
    default => present
  }

  file { $networks_file:
    ensure  => $network_ensure,
    owner   => $user,
    group   => $group,
    mode    => '0644',
    content => template('beegfs/networks.erb'),
    require => Package['beegfs-mgmtd'],
  }

  file { '/etc/beegfs/beegfs-mgmtd.conf':
    ensure  => file,
    owner   => $user,
    group   => $group,
    content => template("beegfs/${_release_major}/beegfs-mgmtd.conf.erb"),
    require => [
      Package['beegfs-mgmtd'],
      File[$interfaces_file],
      File[$networks_file],
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
      File[$networks_file],
    ],
    subscribe  => [
      File['/etc/beegfs/beegfs-mgmtd.conf'],
      File[$interfaces_file],
      File[$networks_file],
    ],
  }
}
