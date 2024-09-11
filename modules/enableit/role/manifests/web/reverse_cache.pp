# Reverse cache web role
class role::web::reverse_cache (
  # FIXME: Need a refactor...
  Enum['drupal'] $variant,
  Eit_types::UUID $secret,
  Eit_types::IP $backendip,
  Stdlib::Port $backendport,
  Optional[Array[String]] $adminacl = undef,
  Optional[Array[Eit_types::AddressPort]] $adminlistens = undef,
  Array[String] $purgers = ['localhost'],
) inherits role::web {
  #vcl, secret and other options should be arguments to THIS class
  # should also setup nginx - if ssl is selected
  #variant - defines which vcl to use..
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
