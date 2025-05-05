# Class: beegfs::client
#
# This module manages beegfs client

# @param user
# @param group
# @param package_ensure
# @param kernel_ensure
# @param interfaces
# @param interfaces_file
# @param networks
# @param networks_file
# @param log_type
# @param log_level
# @param log_dir
# @param mgmtd_host
# @param client_udp_port
# @param helperd_tcp_port
# @param mgmtd_tcp_port
# @param mgmtd_udp_port
# @param kernel_packages
# @param autobuild
# @param autobuild_args
# @param tune_refresh_on_get_attr
# @param tune_file_cache_type
# @param enable_quota
# @param enable_acl
# @param enable_rdma
# @param remote_fsync
# @param conn_auth_file
# @param manage_service
#    Whether service should be managed by puppet and restarted upon config changes
#
# @param sys_file_event_log_mask
#    Specifies which file system events shall be logged by the metadata servers.
#
class beegfs::client (
  String                         $user                     = $beegfs::user,
  String                         $group                    = $beegfs::group,
  Optional[String]               $package_ensure           = $beegfs::package_ensure,
  String                         $kernel_ensure            = present,
  Array[String]                  $interfaces               = ['eth0'],
  Stdlib::AbsolutePath           $interfaces_file          = '/etc/beegfs/interfaces.client',
  Optional[Array[String]]        $networks                 = undef,
  Stdlib::AbsolutePath           $networks_file            = '/etc/beegfs/networks.client',
  Beegfs::Client::LogType        $log_type                 = 'helperd',
  Beegfs::LogLevel               $log_level                = $beegfs::log_level,
  Beegfs::LogDir                 $log_dir                  = $beegfs::log_dir,
  Stdlib::Host                   $mgmtd_host               = $beegfs::mgmtd_host,
  Stdlib::Port                   $client_udp_port          = $beegfs::client_udp_port,
  Stdlib::Port                   $helperd_tcp_port         = $beegfs::helperd_tcp_port,
  Stdlib::Port                   $mgmtd_tcp_port           = $beegfs::mgmtd_tcp_port,
  Stdlib::Port                   $mgmtd_udp_port           = $beegfs::mgmtd_udp_port,
  Array[String]                  $kernel_packages          = $beegfs::params::kernel_packages,
  Boolean                        $autobuild                = true,
  String                         $autobuild_args           = '-j8',
  Boolean                        $tune_refresh_on_get_attr = false,
  String                         $tune_file_cache_type     = 'buffered',
  Boolean                        $enable_quota             = $beegfs::enable_quota,
  Boolean                        $enable_acl               = $beegfs::enable_acl,
  Boolean                        $enable_rdma              = $beegfs::enable_rdma,
  Boolean                        $remote_fsync             = true,
  Optional[Stdlib::AbsolutePath] $conn_auth_file           = $beegfs::conn_auth_file,
  Boolean                        $manage_service           = true,
  Optional[String]               $sys_file_event_log_mask  = undef,
) inherits beegfs {
  stdlib::ensure_packages($kernel_packages, {
      'ensure' => $kernel_ensure,
    }
  )

  $_release_major = beegfs::release_to_major($beegfs::release)

  file { '/etc/beegfs/beegfs-helperd.conf':
    ensure  => file,
    owner   => $user,
    group   => $group,
    mode    => '0644',
    content => template("beegfs/${_release_major}/beegfs-helperd.conf.erb"),
    require => Package['beegfs-helperd'],
  }

  file { $interfaces_file:
    ensure  => file,
    owner   => $user,
    group   => $group,
    mode    => '0644',
    content => template('beegfs/interfaces.erb'),
    require => Package['beegfs-client'],
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
    require => Package['beegfs-client'],
  }

  file { '/etc/beegfs/beegfs-client.conf':
    ensure  => file,
    owner   => $user,
    group   => $group,
    mode    => '0644',
    require => [
      Package['beegfs-utils'],
      File[$interfaces_file],
      File[$networks_file],
    ],
    content => template("beegfs/${_release_major}/beegfs-client.conf.erb"),
  }

  file { '/etc/beegfs/beegfs-client-autobuild.conf':
    ensure  => file,
    owner   => $user,
    group   => $group,
    mode    => '0644',
    content => template("beegfs/${_release_major}/beegfs-client-autobuild.conf.erb"),
    require => Package['beegfs-client'],
  }

  exec { '/etc/init.d/beegfs-client rebuild':
    path        => ['/usr/bin', '/usr/sbin'],
    subscribe   => File['/etc/beegfs/beegfs-client-autobuild.conf'],
    refreshonly => true,
    require     => Package['beegfs-client'],
  }

  package { 'beegfs-helperd':
    ensure  => $package_ensure,
    require => Class['beegfs::install'],
  }

  package { 'beegfs-client':
    ensure  => $package_ensure,
    require => [Class['beegfs::install'], Package[$kernel_packages]],
  }

  service { 'beegfs-helperd':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => Package['beegfs-helperd'],
  }

  concat { '/etc/beegfs/beegfs-mounts.conf':
    owner   => $user,
    group   => $group,
    mode    => '0644',
    require => [Package['beegfs-client']],
  }

  if $manage_service {
    service { 'beegfs-client':
      ensure     => running,
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
      require    => [Package['beegfs-client'],
        Service['beegfs-helperd'],
        File[$interfaces_file],
        File[$networks_file],
      ],
      subscribe  => [
        Concat['/etc/beegfs/beegfs-mounts.conf'],
        File['/etc/beegfs/beegfs-client.conf'],
        File['/etc/beegfs/beegfs-helperd.conf'],
        Exec['/etc/init.d/beegfs-client rebuild'],
        File[$interfaces_file],
        File[$networks_file],
      ],
    }
  }
}
