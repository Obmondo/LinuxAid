# nfs server; should only be included from resource
# profile::storage::nfs::server::export
class profile::storage::nfs::server (
  Boolean $enable                                      = $::common::storage::nfs::server::enable,
  Eit_types::Storage::Nfs::Exports  $exports           = $::common::storage::nfs::server::exports,
  Optional[Eit_types::SimpleString] $listen_interface = $::common::storage::nfs::server::listen_interface,
  Stdlib::Port                      $nfs_port          = 2049,
  Stdlib::Port                      $mountd_port       = 892,

) {

  class { 'nfs::server':
    manage_firewall => false,
  }

}
