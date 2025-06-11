# A class to install Java and JNA packages.
# @param aptkey [hash] If supplied, this should be a hash of `apt::key`
#   resources that will be passed to the create_resources function.
#   This is ignored on non-Debian systems.
# @param aptsource [hash] If supplied, this should be a hash of
#   `apt::source` resources that will be passed to the create_resources
#   function.  This is ignored on non-Red Hat`
# @param jna_ensure [string] Is passed to the package reference for the JNA
#   package.  Valid values are `present` or a version number.
# @param jna_package_name [string] The name of the JNA package.
# @param package_ensure [string] Is passed to the package reference for the JRE/JDK
#   package.  Valid values are `present` or a version number.
# @param package_name [string] The name of the Java package to be installed.
# @param yumrepo [hash] If supplied, this should be a hash of *yumrepo*
#   resources that will be passed to the create_resources function.
#   This is ignored on non-Red Hat systems.
class cassandra::java (
  $aptkey           = undef,
  $aptsource        = undef,
  $jna_ensure       = present,
  $jna_package_name = $cassandra::params::jna_package_name,
  $package_ensure   = present,
  $package_name     = $cassandra::params::java_package,
  $yumrepo          = undef,
) inherits cassandra::params {
  if $facts['os']['family'] == 'RedHat' and $yumrepo != undef {
    $yumrepo_defaults = {
      'before' => Package[$package_name],
    }

    create_resources(yumrepo, $yumrepo, $yumrepo_defaults)
  }

  if $facts['os']['family'] == 'Debian' {
    if $aptkey != undef {
      $aptkey_defaults = {
        'before' => Package[$package_name],
      }

      include apt
      create_resources(apt::key, $aptkey, $aptkey_defaults)
    }

    if $aptsource != undef {
      exec { 'cassandra::java::apt_update':
        refreshonly => true,
        command     => '/bin/true',
        require     => Exec['apt_update'],
        before      => Package[$package_name],
      }

      $aptsource_defaults = {
        'notify' => Exec['cassandra::java::apt_update'],
      }

      create_resources(apt::source, $aptsource, $aptsource_defaults)
    }
  }

  package { $package_name:
    ensure => $package_ensure,
  }

  package { $jna_package_name:
    ensure => $jna_ensure,
  }
}
