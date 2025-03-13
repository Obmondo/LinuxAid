
# @summary Reverse cache web role
#
# @param variant Defines which VCL to use.
#
# @param secret The secret for authentication.
#
# @param backendip The backend IP address.
#
# @param backendport The backend port.
#
# @param adminacl The admin ACL. Defaults to undef.
#
# @param adminlistens The admin listen addresses. Defaults to undef.
#
# @param purgers The purgers. Defaults to ['localhost'].
#
class role::web::reverse_cache (
  Enum['drupal'] $variant,
  Eit_types::UUID $secret,
  Eit_types::IP $backendip,
  Stdlib::Port $backendport,
  Optional[Array[String]] $adminacl = undef,
  Optional[Array[Eit_types::AddressPort]] $adminlistens = undef,
  Array[String] $purgers = ['localhost'],
) inherits role::web {

  # vcl, secret and other options should be arguments to THIS class
  # should also setup nginx - if ssl is selected
  class { '::profile::varnish':
    backendip    => $backendip,
    backendport  => $backendport,
    adminacl     => $adminacl,
    adminlistens => $adminlistens,
    variant      => $variant,
    purgers      => $purgers,
    secret       => $secret,
  }
}
