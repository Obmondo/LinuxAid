# Sanoid
class sanoid (
  Boolean $ensure_package,
  Boolean $ensure_service,
  String  $config_file,
  String  $package_name,

  Array[String]     $allow_sync_from,
  Sanoid::Pools     $pools,
  Sanoid::Templates $templates,

  Sanoid::Syncoid::Replications $replications,

) {

  include sanoid::install
  include sanoid::config
  include sanoid::service
  include sanoid::syncoid
}
