# Sanoid Install packages
class sanoid::install (
  Stdlib::Ensure::Package $ensure       = $sanoid::ensure_package,
  String                  $package_name = $sanoid::package_name,
) {

  package {
    [
      $package_name,
      'lz4',
      'lzop',
      'mbuffer',
    ]:
    ensure => $ensure,
    notify => File["/etc/default/${sanoid::config_file}"],
  }
}
