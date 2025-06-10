# Package installation function
#
# Tries to look up package names in hiera. If not found, uses package name as-is.
#
# @example
# Install emacs (will be in installed state)
# package::install('emacs')
#
# Remove the rsync package
# package::install('rsync', 'absent')
#
# Install hp-health with a specific version, and notify some service
# package::install('hp-health', {notify => Service['some-servicd']}))
#
# Install diamond package with a specific version, but does not set a pin
# package::install('diamond', '4.0.471')
#
# @param packages One or more package names
# @param parameters Additional parameters. These are merged with `status`.

function package::install (
  Variant[String, Array[String]] $packages,
  Variant[Stdlib::Ensure::Package, Hash[String, Any]] $parameters = {},
) {

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
