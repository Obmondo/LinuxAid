# beegfs
class profile::storage::beegfs (
  Boolean                     $enable            = $::role::storage::beegfs::enable,
  Eit_types::Host             $mgmtd_host        = $::role::storage::beegfs::mgmtd_host,
  Array[Stdlib::Absolutepath] $storage_directory = $::role::storage::beegfs::storage_directory,
  Boolean                     $client            = $::role::storage::beegfs::client,
  Boolean                     $mgmtd             = $::role::storage::beegfs::mgmtd,
  Boolean                     $storage           = $::role::storage::beegfs::storage,
  Boolean                     $meta              = $::role::storage::beegfs::meta,
  Boolean                     $admon             = $::role::storage::beegfs::admon,
  Stdlib::Port                $admon_http_port   = $::role::storage::beegfs::admon_http_port,
  Stdlib::Port                $storage_port      = $::role::storage::beegfs::storage_port,
  Stdlib::Port                $client_udp_port   = $::role::storage::beegfs::client_udp_port,
  Stdlib::Port                $meta_port         = $::role::storage::beegfs::meta_port,
  Stdlib::Port                $helperd_tcp_port  = $::role::storage::beegfs::helperd_tcp_port,
  Stdlib::Port                $admon_udp_port    = $::role::storage::beegfs::admon_udp_port,
  Stdlib::Port                $mgmtd_port        = $::role::storage::beegfs::mgmtd_port,
  Array[String]               $interfaces        = $::role::storage::beegfs::interfaces,
) inherits ::profile::storage {

  $_release = '7.1'

  if $enable {
    class { 'beegfs':
      release    => $_release,
      mgmtd_host => $mgmtd_host,
    }

    if $client {
      class { 'beegfs::client':
        interfaces => $interfaces,
      }

      firewall_multi { '100 beegfs client':
        ensure  => present,
        proto   => ['udp'],
        dport   => $client_udp_port,
        iniface => $interfaces,
        jump    => 'accept',
      }
    }

    if $mgmtd {
      class { 'beegfs::mgmtd':
        interfaces        => $interfaces,
        allow_new_servers => true,
        allow_new_targets => true
      }

      firewall_multi { '100 beegfs mgmtd':
        ensure  => present,
        proto   => ['tcp', 'udp'],
        dport   => $mgmtd_port,
        iniface => $interfaces,
        jump    => 'accept',
      }
    }

    if $meta {
      class { 'beegfs::meta':
        mgmtd_host => $mgmtd_host,
        interfaces => $interfaces,
      }

      firewall_multi { '100 beegfs meta':
        ensure  => present,
        proto   => ['tcp', 'udp'],
        dport   => $meta_port,
        iniface => $interfaces,
        jump    => 'accept',
      }
    }

    if $storage {
      class { 'beegfs::storage':
        mgmtd_host        => $mgmtd_host,
        interfaces        => $interfaces,
        storage_directory => $storage_directory,
      }

      firewall_multi { '100 beegfs storage':
        ensure  => present,
        proto   => ['tcp', 'udp'],
        dport   => $storage_port,
        iniface => $interfaces,
        jump    => 'accept',
      }
    }

    if $admon {
      class { 'beegfs::admon':
        interfaces      => $interfaces,
        admon_http_port => $admon_http_port,
      }

      firewall_multi { '100 beegfs admon http':
        ensure  => present,
        proto   => ['tcp'],
        dport   => $admon_http_port,
        iniface => $interfaces,
        jump    => 'accept',
      }
    }
  } else {
    service {[
      'beegfs-client.service',
      'beegfs-helperd.service',
      'beegfs-meta.service',
      'beegfs-mgmtd.service',
      'beegfs-storage.service',
    ]:
      ensure => stopped,
      enable => false,
    }

    package { [
      'beegfs-client',
      'beegfs-common',
      'beegfs-helperd',
      'beegfs-meta',
      'beegfs-storage',
      'beegfs-utils',
      'beegfs-admon',
      'beegfs-debuginfo',
      'beegfs-mgmtd',
      'beegfs-mon',
      'beegfs-mon-grafana',
      'beegfs-utils-devel',
    ]:
      ensure => 'absent',
    }

  }

}
