# Install some random packages
class common::package (
  Boolean                $install_default_packages  = false,
  Hash[
    String,
    Struct[{
      ensure => Optional[Variant[Enum['latest', 'present', 'purge', 'absent', 'installed'], String]],
      noop   => Optional[Boolean],
    }]
  ] $manage = {},
  Array[String]           $default_packages         = [],
  Array[String]           $removed_packages         = [],
  Array[String]           $required_packages        = [],
) {
  $manage.each | $package_name, $status | {
    package { $package_name :
      # make sure the default is installed, even if it should change
      ensure => pick($status['ensure'], installed),
      noop   => $status['noop'],
    }
  }

  $_packages = $required_packages + if $install_default_packages {
    $default_packages
  } else {
    []
  }

  # Packages to install are all packages except those ending with a `-` (dash)
  $_default_removed = $_packages.filter |$package| {
    $package =~ /-$/
  }
  $_default_installed = $_packages - $_default_removed

  package::install($_default_installed)
  package::remove($_default_removed.map |$p| {
    regsubst($p, '^(.*?)-?$', '\1', 'E')
  } + $removed_packages)
}
