# @summary Class for managing the installation and removal of packages
#
# @param install_default_packages Boolean to determine whether to install default packages. Defaults to false.
#
# @param manage Hash mapping package names to options for managing them.
#
# @param default_packages Array of package names to install by default.
#
# @param removed_packages Array of package names to remove.
#
# @param required_packages Array of package names that are required to be installed.
#
class common::package (
  Boolean                $install_default_packages  = false,
  Hash[
    String,
    Struct[{
      ensure => Optional[Stdlib::Ensure::Package],
      noop   => Optional[Boolean],
      pin    => Optional[String],
    }]
  ]                       $manage                   = {},
  Array[String]           $default_packages         = [],
  Array[String]           $removed_packages         = [],
  Array[String]           $required_packages        = [],
) {
  # Manage package
  $manage.each |$package_name, $options| {
    confine($options['pin'], $options['ensure'] in ['present', 'absent'] or $options['ensure'] =~ Boolean, 'Package pinning requires an explicit package version') #lint:ignore:140chars
    stdlib::ensure_packages($package_name, {
      # make sure the default is installed, even if it should change
      ensure => pick($options['ensure'], installed),
      noop   => $options['noop'],
    })
    if $options['pin'] {
      case $facts['package_provider'] {
        'apt': {
          apt::pin { "pin ${package_name}":
            version  => $options['pin'],
            priority => 999,
            packages => $package_name,
          }
        }
        /^(yum|dnf)$/: {
          $release = split($options['pin'], '-')
          yum::versionlock { $package_name:
            ensure  => present,
            version => $release[0],
            # NOTE: some package has like el8_10 (8.10) and some just have el8, so * will help to catch those
            release => "${release[1]}.el${facts['os']['release']['major']}*",
            arch    => $facts['os']['architecture'],
          }
        }
        'zypper': {
          $full_package_name = "${package_name}-${options['pin']}-*.sles${facts['os']['release']['major']}*.${facts['os']['architecture']}"
          zypprepo::versionlock { $full_package_name:
            ensure => present,
          }
        }
        default: {
          info('Unsupported package provider, please raise issue on github')
        }
      }
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
