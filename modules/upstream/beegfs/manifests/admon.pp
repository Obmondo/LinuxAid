# Class: beegfs::admon
#
# This module manages beegfs admon
#
# @param enable
# @param user
# @param group
# @param package_ensure
# @param kernel_ensure
# @param interfaces
# @param interfaces_file
# @param networks
# @param networks_file
# @param log_dir
# @param log_type
# @param log_level
# @param mgmtd_host
# @param admon_http_port
# @param admon_udp_port
# @param client_udp_port
# @param helperd_tcp_port
# @param mgmtd_tcp_port
# @param mgmtd_udp_port
# @param kernel_packages
# @param autobuild
# @param autobuild_args
# @param tune_refresh_on_get_attr
# @param enable_quota
# @param enable_acl
# @param admon_db_file
#
class beegfs::admon (
  Boolean                 $enable                   = true,
  String                  $user                     = $beegfs::user,
  String                  $group                    = $beegfs::group,
  String                  $package_ensure           = $beegfs::package_ensure,
  String                  $kernel_ensure            = present,
  Array[String]           $interfaces               = ['eth0'],
  Stdlib::AbsolutePath    $interfaces_file          = '/etc/beegfs/interfaces.admon',
  Optional[Array[String]] $networks                 = undef,
  Stdlib::AbsolutePath    $networks_file            = '/etc/beegfs/networks.admon',
  Beegfs::LogDir          $log_dir                  = $beegfs::log_dir,
  Beegfs::LogType         $log_type                 = $beegfs::log_type,
  Beegfs::LogLevel        $log_level                = $beegfs::log_level,
  Stdlib::Host            $mgmtd_host               = $beegfs::mgmtd_host,
  Stdlib::Port            $admon_http_port          = $beegfs::admon_http_port,
  Stdlib::Port            $admon_udp_port           = $beegfs::admon_udp_port,
  Stdlib::Port            $client_udp_port          = $beegfs::client_udp_port,
  Stdlib::Port            $helperd_tcp_port         = $beegfs::helperd_tcp_port,
  Stdlib::Port            $mgmtd_tcp_port           = $beegfs::mgmtd_tcp_port,
  Stdlib::Port            $mgmtd_udp_port           = $beegfs::mgmtd_udp_port,
  Array[String]           $kernel_packages          = $beegfs::params::kernel_packages,
  Boolean                 $autobuild                = true,
  String                  $autobuild_args           = '-j8',
  Boolean                 $tune_refresh_on_get_attr = false,
  Boolean                 $enable_quota             = $beegfs::enable_quota,
  Boolean                 $enable_acl               = $beegfs::enable_acl,
  Stdlib::AbsolutePath    $admon_db_file            = $beegfs::admon_db_file,
) inherits beegfs {
  $_release_major = beegfs::release_to_major($beegfs::release)

  package { 'beegfs-admon':
    ensure  => $package_ensure,
    require => Class['beegfs::install'],
  }

  file { $interfaces_file:
    ensure  => file,
    owner   => $user,
    group   => $group,
    mode    => '0644',
    content => template('beegfs/interfaces.erb'),
    require => Package['beegfs-admon'],
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
    require => Package['beegfs-admon'],
  }

  file { '/etc/beegfs/beegfs-admon.conf':
    ensure  => file,
    owner   => $user,
    group   => $group,
    content => template("beegfs/${_release_major}/beegfs-admon.conf.erb"),
    require => [
      Package['beegfs-mgmtd'],
      File[$interfaces_file],
      File[$networks_file],
    ],
  }

  service { 'beegfs-admon':
    ensure     => running,
    enable     => $enable,
    hasstatus  => true,
    hasrestart => true,
    require    => [
      Package['beegfs-admon'],
      File[$interfaces_file],
      File[$networks_file],
    ],
    subscribe  => [
      File['/etc/beegfs/beegfs-admon.conf'],
      File[$interfaces_file],
      File[$networks_file],
    ],
  }
}
