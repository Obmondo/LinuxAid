# Sanoid Install packages
class sanoid::install (
  Boolean $ensure       = $sanoid::ensure_package,
  String  $package_name = $sanoid::package_name,
) {

  package {
    [
      $package_name,
      'lz4',
      'lzop',
      'mbuffer',
    ]:
    ensure => stdlib::ensure($ensure, 'package'),
    notify => File["/etc/sanoid/${sanoid::config_file}"],
  }
}
