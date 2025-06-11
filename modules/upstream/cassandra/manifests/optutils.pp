# A class to install the optional Cassandra tools package.
# @param package_ensure [string] Can be `present`, `latest` or a specific
#   version number.
# @param package_name [string] The name of the optional utilities package to
#   be installed.
class cassandra::optutils (
  $package_ensure = 'present',
  $package_name   = $cassandra::params::optutils_package_name,
) inherits cassandra::params {
  include 'cassandra'

  package { $package_name:
    ensure  => $package_ensure,
    require => Class['cassandra'],
  }
}
