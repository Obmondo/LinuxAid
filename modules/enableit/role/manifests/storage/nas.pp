
# @summary Storage Nas roleclass
#
class role::storage::nas () inherits role::storage {

  confine(!($facts['init_system'] in ['systemd']), 'Only systemd is supported')

  class { 'profile::storage::block':
    devices => {},
  }

  class { 'profile::storage::backuphost': }
}
