# NFS server and exports
class common::storage::nfs (
  Boolean $enable            = false,
  Boolean $unmount_snapshots = true,
) {

  if lookup('common::storage::nfs::server::enable', Boolean, undef, false) {
    contain ::common::storage::nfs::server
  }

  if $enable {
    include ::profile::storage::nfs
  }
}
