# NFS server and exports
class common::storage::nfs::server (
  Boolean                           $enable           = false,
  Optional[Eit_types::SimpleString] $listen_interface = undef,
  Hash[
    String,
    Struct[
      {
        path    => Stdlib::Absolutepath,
        options => Array[String[1]],
        clients => Array[String[1]],
      }]
  ] $exports = {},
) {

  $exports.each |$_name, $params| {
    profile::storage::nfs::server::export { $_name:
      * => $params,
    }
  }

}
