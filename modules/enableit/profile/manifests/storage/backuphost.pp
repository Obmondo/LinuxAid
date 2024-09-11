# Storage backuphost profile
class profile::storage::backuphost (

) {

  include ::common::backup::borg

  Ssh_authorized_key <<| tag == "obmondo-backup-${::customer}-${trusted['hostname']}" |>>
}
