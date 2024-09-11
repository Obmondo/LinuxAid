# Storage backuphost role
class role::storage::backuphost (

) inherits role::storage {

  include ::common::backup::borg

  Ssh_authorized_key <<| tag == "obmondo-backup-${::customer}-${trusted['hostname']}" |>>
}
