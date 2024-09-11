# == Class: nfs::server
#
# Installs the NFS server software, allowing usage of the nfs::export
# resource type.
#
# === Variables
#
# This module requires no variables.
#
# === Examples
#
#  class { 'nfs::server':
#    ensure => true,
#    enable => true,
#  }

# === Authors
# - Rune Juhl Jacobsen <runejuhl@enableit.dk>
#
# Module based on work by:
#  - Joseph Beard <joseph@josephbeard.net>
#
# === Copyright
#
# Copyright 2014 Joseph Beard
#
class nfs::server (
  String $service_name,         # provided by hiera
  Array[String] $packages,      # provided by hiera
  Array[String] $additional_services               = [],
  Boolean $ensure                                  = true,
  Boolean $enable                                  = true,
  Boolean $manage_firewall                         = true,
  Array[String] $rpc_nfsd_args                     = [],
  Array[String] $rpc_mountd_opts                   = [],
  Integer[0, default] $rpc_nfsd_count              = 8,
  Integer[0, default] $nfsd_v4_grace               = 90,
  Integer[0, default] $nfsd_v4_lease               = 90,
  Stdlib::Port $nfs_port                        = 2049,
  Stdlib::Port $mountd_port                     = 892,
  Boolean $gss_use_proxy                           = true,
  Array[String] $sm_notify_args                    = [],
  Array[String] $rpc_idmapd_args                   = [],
  Array[String] $rpc_gssd_args                     = [],
  Array[String] $rpc_svcgssd_args                  = [],
  Array[String] $rpc_blkmapd_args                  = [],
  Optional[Array[String]] $listen_interfaces       = undef,
) inherits ::nfs {

  unless ($facts['os']['family'] in ['RedHat', 'Debian', 'Suse']) {
    fail('nfs::server not supported')
  }

  contain ::nfs::client

  # Ensure that we don't try to install required packages from two classes; on
  # RHEL6 the NFS client and server packages are the same
  $_server_packages = $packages-$::nfs::client::packages

  package { $_server_packages:
    ensure => ensure_present($ensure),
    before => delete_undef_values([
      Class['::nfs::server::config'],
      unless empty($additional_services) { Service[$additional_services]} ,
    ]),
  }

  class { '::nfs::server::config':
    ensure => $ensure,
  }

  service {
    default:
      ensure => $ensure,
      enable => $enable,
      ;

    'rpcbind':
      ;

    $service_name:
      require =>
      delete_undef_values([
        Class['::nfs::server::config'],
        Service['rpcbind'],
        unless empty($additional_services) { Service[$additional_services]} ,
      ]),
      ;

    $additional_services:
      require => Class['::nfs::server::config'],
      ;
  }

  if $manage_firewall {
    $_interfaces = pick($listen_interfaces, $facts['networking']['primary'])

    firewall_multi { '000 allow nfs server':
      dport   => [$mountd_port, $nfs_port],
      proto   => 'tcp',
      jump    => accept,
      iniface => $_interfaces,
    }
  }
}
