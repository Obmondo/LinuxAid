# @summary BeegFS class for managing storage
#
# @param enable Flag to enable or disable the BeegFS role.
#
# @param mgmtd_host The host for the management daemon. Defaults to 'localhost'.
#
# @param client Flag to indicate if the client should be installed. Defaults to true.
#
# @param mgmtd Flag to indicate if the management daemon should be installed. Defaults to false.
#
# @param storage Flag to indicate if the storage service should be enabled. Defaults to true.
#
# @param meta Flag to indicate if the metadata service should be enabled. Defaults to true.
#
# @param admon Flag to indicate if the administration service should be enabled. Defaults to false.
#
# @param interfaces An array of network interfaces to bind to. Defaults to an empty array.
#
# @param __blendable A flag for blendable functionality.
#
# @groups services client, mgmtd, storage, meta, admon.
#
# @groups management mgmtd_host.
#
# @groups network interfaces.
#
# @groups blendable __blendable.
#
# @groups enable enable.
#
class role::storage::beegfs (
  Boolean         $enable,
  Eit_types::Host $mgmtd_host = 'localhost',
  Boolean         $client     = true,
  Boolean         $mgmtd      = false,
  Boolean         $storage    = true,
  Boolean         $meta       = true,
  Boolean         $admon      = false,
  Array[String]   $interfaces = [],
  Boolean         $__blendable,
) {
  confine($enable,
          $::common::user_management::security::selinux::enable,
          'selinux must be disabled')

  contain role::storage::beegfs::client
  contain role::storage::beegfs::mgmtd
  contain role::storage::beegfs::meta
  contain role::storage::beegfs::storage
  contain role::storage::beegfs::admon
  contain 'profile::storage::beegfs'
}
