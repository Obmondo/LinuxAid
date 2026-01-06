# @summary Storage nfs role class
#
# @param exports The exports for the NFS storage. Defaults to undef.
#
# @groups exports exports
#
class role::storage::nfs (
  Optional[Hash[
    String,
    Struct[
      {
        path    => Stdlib::Absolutepath,
        options => Array[String[1]],
        clients => Array[String[1]],
      }
    ]
  ]] $exports = undef,
) inherits role::storage {

  class { 'profile::storage::nfs':
    exports => $exports,
  }
}
