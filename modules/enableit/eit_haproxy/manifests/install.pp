# Haproxy Install
class eit_haproxy::install (
  String                     $package_name,
  Eit_types::Package_version $ensure = 'present',
) {

  package { $package_name:
    ensure => $eit_haproxy::version,
    notify => Service[$eit_haproxy::service_name],
  }

  package { 'haproxyctl':
    ensure => 'present'
  }
}
