# @summary Class for managing NFS server and exports
#
# @param enable Whether to enable the NFS server. Defaults to false.
#
# @groups server_config enable
#
class common::storage::nfs (
  Boolean $enable = false,
) {
  if lookup('common::storage::nfs::server::enable', Boolean, undef, false) {
    contain ::common::storage::nfs::server
  }
  if $enable {
    include ::profile::storage::nfs
  }
}
