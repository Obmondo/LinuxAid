# Class: beegfs::storage
#
# @desc beegfs storage service
#
# @param enable
# @param storage_directory
# @param allow_first_run_init
# @param mgmtd_host
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
# @param mgmtd_tcp_port
# @param mgmtd_udp_port
# @param enable_quota
# @param enable_rdma
# @param conn_auth_file
#
class beegfs::storage (
  Boolean                        $enable               = true,
  Array[Stdlib::AbsolutePath]    $storage_directory    = $beegfs::storage_directory,
  Boolean                        $allow_first_run_init = true,
  Stdlib::Host                   $mgmtd_host           = $beegfs::mgmtd_host,
  Beegfs::LogDir                 $log_dir              = $beegfs::log_dir,
  Beegfs::LogType                $log_type             = $beegfs::log_type,
  Beegfs::LogLevel               $log_level            = $beegfs::log_level,
  String                         $user                 = $beegfs::user,
  String                         $group                = $beegfs::group,
  String                         $package_ensure       = $beegfs::package_ensure,
  Array[String]                  $interfaces           = ['eth0'],
  Stdlib::AbsolutePath           $interfaces_file      = '/etc/beegfs/interfaces.storage',
  Optional[Array[String]]        $networks             = undef,
  Stdlib::AbsolutePath           $networks_file        = '/etc/beegfs/networks.storage',
  Stdlib::Port                   $mgmtd_tcp_port       = 8008,
  Stdlib::Port                   $mgmtd_udp_port       = 8008,
  Boolean                        $enable_quota         = $beegfs::enable_quota,
  Boolean                        $enable_rdma          = $beegfs::enable_rdma,
  Optional[Stdlib::AbsolutePath] $conn_auth_file       = $beegfs::conn_auth_file,
) inherits beegfs {
  $_release_major = beegfs::release_to_major($beegfs::release)

  file { $storage_directory:
    ensure => directory,
    owner  => $user,
    group  => $group,
    before => Package['beegfs-storage'],
  }

  package { 'beegfs-storage':
    ensure  => $package_ensure,
    require => Class['beegfs::install'],
  }

  file { $interfaces_file:
    ensure  => file,
    owner   => $user,
    group   => $group,
    mode    => '0644',
    content => template('beegfs/interfaces.erb'),
    require => Package['beegfs-storage'],
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
    require => Package['beegfs-storage'],
  }

  file { '/etc/beegfs/beegfs-storage.conf':
    ensure  => file,
    owner   => $user,
    group   => $group,
    mode    => '0644',
    content => template("beegfs/${_release_major}/beegfs-storage.conf.erb"),
    require => [
      File[$interfaces_file],
      File[$networks_file],
      Package['beegfs-storage'],
    ],
  }

  service { 'beegfs-storage':
    ensure     => running,
    enable     => $enable,
    hasstatus  => true,
    hasrestart => true,
    require    => Package['beegfs-storage'],
    subscribe  => [
      File['/etc/beegfs/beegfs-storage.conf'],
      File[$interfaces_file],
      File[$networks_file],
    ],
  }
}
