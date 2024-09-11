# Nfs Install
class nfs::server::install (
  Array[String] $packages,
  Enum['installed', 'absent'] $ensure = 'installed',
) {
  package { $packages:
    ensure => $ensure,
  }
}
