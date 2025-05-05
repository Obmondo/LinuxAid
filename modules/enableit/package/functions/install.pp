# Package installation function
#
# Tries to look up package names in hiera. If not found, uses package name as-is.
#
# @example
#   package::install('emacs')
#   package::install('rsync', 'absent')
#   package::install('python-pymongo', {notify => Service['diamond']})
#   package::install('hp-health', 'present' , '9.4.0.1.7-5.')
#   package::install('diamond', {notify => Service['diamond']} , '4.0.471')
#
# @param package_names One or more package names
# @param status Package status
# @param parameters Additional parameters. These are merged with `status`.

function package::install (
  Variant[String, Array[String]] $packages,
  Variant[Boolean, Enum['present', 'absent'], Hash[String, Any], String] $parameters = {},
  Boolean $pin = false,
) {

  confine($pin, $::facts['os']['family'] != 'Debian', 'Package pinning only supported on Debian-based systems')
  confine($pin, $parameters in ['present', 'absent'] or $parameters =~ Boolean, 'Package pinning requires an explicit package version')

  # Packages
  $_packages = case $packages {
    String: {
      [$packages]
    }
    default: {
      $packages
    }
  }

  # Parameters
  $_parameters = case $parameters {
    Boolean, String: {
      {ensure => $parameters}
    }
    default: {
      $parameters
    }
  }

  if $pin {
    $_name = join($_packages, ', ')
    apt::pin { $_name:
      packages => $_packages,
      version  => $parameters,
      priority => 999,
    }
  }

  # Install/Remove Package
  $install_packages = package::lookup($_packages)

  # Use the real resource instead of `stdlib::ensure_packages` from stdlib; this makes
  # it possible to set the name of the package resource to the name we use
  # internally allowing us to refer to it in e.g. metaparameters.
  $install_packages.each |$_name, $_package| {
    [$_package_name, $_lookup_parameters] = $_package

    if !defined(Package[$_package_name]) {
      $_install_parameters = [
        {
          ensure => 'present',
        },
        $_lookup_parameters,
        $_parameters,
      ].delete_undef_values.reduce |$acc, $x| {
        $acc + $x
      }

      package { $_name:
        name => $_package_name,
        *    => $_install_parameters,
      }
    }

  }
}
