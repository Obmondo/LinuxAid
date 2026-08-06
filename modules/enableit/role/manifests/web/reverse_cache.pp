
# @summary Reverse cache web role
#
# @param secret The secret for authentication.
#
# @param backendip The backend IP address.
#
# @param backendport The backend port.
#
# @param adminacl The admin ACL. Defaults to undef.
#
# @groups backend backendip, backendport.
#
# @groups admin adminacl.
#
# @groups auth secret.
#
class role::web::reverse_cache (
  Eit_types::UUID $secret,
  Eit_types::IP $backendip,
  Stdlib::Port $backendport,
  Optional[Array[String]] $adminacl = undef,
) inherits role::web {

  # vcl, secret and other options should be arguments to THIS class
  # should also setup nginx - if ssl is selected
  class { '::profile::web::varnish':
    backendip   => $backendip,
    backendport => $backendport,
    adminacl    => $adminacl,
    variant     => 'drupal',
    purgers     => ['localhost'],
    secret      => $secret,
  }
}
