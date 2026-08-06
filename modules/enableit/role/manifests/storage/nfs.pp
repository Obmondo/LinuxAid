# @summary Storage nfs role class
#
class role::storage::nfs () inherits role::storage {

  class { 'profile::storage::nfs':
    exports => undef,
  }
}
