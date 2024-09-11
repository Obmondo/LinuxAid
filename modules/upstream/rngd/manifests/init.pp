# Installs rngd.
#
# @example Declaring the class
#   include ::rngd
#
# @example Using a different hardware RNG
#   class { '::rngd':
#     hwrng_device => '/dev/urandom',
#   }
#
# @param hasstatus Whether the service has a working status command.
# @param hwrng_device Path to a hardware RNG device.
# @param package_name The name of the package.
# @param service_manage Whether to manage the service.
# @param service_name Name of the service.
class rngd (
  Boolean                        $hasstatus      = $::rngd::params::hasstatus,
  Optional[Stdlib::Absolutepath] $hwrng_device   = undef,
  String                         $package_name   = $::rngd::params::package_name,
  Boolean                        $service_manage = $::rngd::params::service_manage,
  String                         $service_name   = $::rngd::params::service_name
) inherits ::rngd::params {

  contain ::rngd::install
  contain ::rngd::config
  contain ::rngd::service

  Class['::rngd::install'] -> Class['::rngd::config']
    ~> Class['::rngd::service']
}
