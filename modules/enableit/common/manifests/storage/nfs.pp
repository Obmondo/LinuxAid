# @summary Class for managing NFS server and exports
#
# @param enable Whether to enable the NFS server. Defaults to false.
#
# @param unmount_snapshots Whether to unmount snapshots. Defaults to true.
#
# @groups server_config enable, unmount_snapshots
#
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
