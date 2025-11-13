# Sanoid
class sanoid (
  Stdlib::Ensure::Package $ensure_package,
  Stdlib::Ensure::Service $ensure_service,
  String                  $config_file,
  String                  $package_name,
  Sanoid::Pools           $pools,
  Sanoid::Templates       $templates,
) {

  include sanoid::install
  include sanoid::config
  include sanoid::service
  include sanoid::syncoid
}
