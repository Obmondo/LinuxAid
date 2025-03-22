
# @summary A role class for the storage backup host
#
# This role class inherits from the `role::storage` class and includes 
# the `common::backup::borg` class to set up backup functionality 
# using Borg.
#
class role::storage::backuphost () inherits role::storage {
  include ::common::backup::borg

  Ssh_authorized_key <<| tag == "obmondo-backup-${facts['customer']}-${trusted['hostname']}" |>>
}
