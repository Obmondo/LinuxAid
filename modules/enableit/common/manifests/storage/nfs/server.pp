# @summary Class for managing NFS server and exports
#
# @param enable Enable or disable the NFS server. Defaults to false.
#
# @param listen_interface Optional network interface to listen on. Defaults to undef.
#
# @param exports Hash of export configurations, where each key is the export name and value is a struct containing path, options, and clients.
#
# @groups server enable, listen_interface.
#
# @groups exports exports.
#
class common::storage::nfs::server (
  Boolean $enable           = false,
  Optional[Eit_types::SimpleString] $listen_interface = undef,
  Hash[
    String,
    Struct[
      {
        path    => Stdlib::Absolutepath,
        options => Array[String[1]],
        clients => Array[String[1]],
      }
    ]
  ] $exports = {},
) {
  $exports.each |$_name, $params| {
    profile::storage::nfs::server::export { $_name:
      * => $params,
    }
  }
}
