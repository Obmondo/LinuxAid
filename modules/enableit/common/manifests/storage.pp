# @summary Class for managing storage configurations
#
# @param mounts Hash of mounts configurations. Defaults to an empty hash.
#
class common::storage (
  Eit_types::Common::Storage::Mounts $mounts = {},
) {

  if lookup('common::storage::zfs::enable', Boolean, undef, false) {
    contain common::storage::zfs
  }

  if lookup('common::storage::nfs::enable', Boolean, undef, false) {
    contain common::storage::nfs
  }

  if lookup('common::storage::samba::enable', Boolean, undef, false) {
    contain common::storage::samba
  }

  unless lookup('common::storage::quota::quotas', Hash, undef, {}).empty {
    contain common::storage::quota
  }

  unless lookup('common::storage::mounts', Hash, undef, {}).empty {
    contain profile::storage
  }
}
