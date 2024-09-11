# Class: beegfs::meta
#
# This module manages beegfs meta service
#
class beegfs::meta (
  Boolean              $enable               = true,
  Stdlib::AbsolutePath $meta_directory       = $beegfs::meta_directory,
  Boolean              $allow_first_run_init = true,
  Stdlib::Host         $mgmtd_host           = $beegfs::mgmtd_host,
  Beegfs::LogDir       $log_dir              = $beegfs::log_dir,
  Beegfs::LogType      $log_type             = $beegfs::log_type,
  Beegfs::LogLevel     $log_level            = $beegfs::log_level,
  String               $user                 = $beegfs::user,
  String               $group                = $beegfs::group,
                       $package_ensure       = hiera('beegfs::package_ensure', $beegfs::package_ensure),
  Array[String]        $interfaces           = ['eth0'],
  Stdlib::AbsolutePath $interfaces_file      = '/etc/beegfs/interfaces.meta',
  Beegfs::Release      $release              = $beegfs::release,
  Boolean              $enable_acl           = $beegfs::enable_acl,
  Stdlib::Port         $meta_tcp_port        = $beegfs::meta_tcp_port,
  Stdlib::Port         $meta_udp_port        = $beegfs::meta_udp_port,
  Stdlib::Port         $mgmtd_tcp_port       = $beegfs::mgmtd_tcp_port,
  Stdlib::Port         $mgmtd_udp_port       = $beegfs::mgmtd_udp_port,

) inherits ::beegfs {

  require ::beegfs::install

  package { 'beegfs-meta':
    ensure => $package_ensure,
  }

  $_release_major = beegfs::release_to_major($release)

  file { $interfaces_file:
    ensure  => present,
    owner   => $user,
    group   => $group,
    mode    => '0644',
    content => template('beegfs/interfaces.erb'),
  }

  file { '/etc/beegfs/beegfs-meta.conf':
    ensure  => present,
    owner   => $user,
    group   => $group,
    mode    => '0644',
    content => template("beegfs/${_release_major}/beegfs-meta.conf.erb"),
    require => [
      File[$interfaces_file],
      Package['beegfs-meta'],
    ],
  }

  service { 'beegfs-meta':
    ensure     => running,
    enable     => $enable,
    hasstatus  => true,
    hasrestart => true,
    require    => Package['beegfs-meta'],
    subscribe  => [
      File['/etc/beegfs/beegfs-meta.conf'],
      File[$interfaces_file]
    ],
  }
}
