# Haproxy Install
class eit_haproxy::install (
  String                     $package_name,
  Eit_types::Version         $ensure = 'present',
) {
  $_package_ensure = $eit_haproxy::version =~ /^\d+\.\d+$/ ? {
    true    => 'present',
    default => $eit_haproxy::version,
  }

  package { $package_name:
    ensure => $_package_ensure,
    notify => Service[$eit_haproxy::service_name],
  }

  package { 'haproxyctl':
    ensure => 'present',
  }
}
