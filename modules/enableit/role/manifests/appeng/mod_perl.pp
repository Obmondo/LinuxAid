
# @summary Class for managing the Mod Perl role
#
# @param url The URL for the application. Defaults to undef.
#
# @param http_server The HTTP server to use. Defaults to 'apache'.
#
class role::appeng::mod_perl (
  Optional[Eit_types::URL] $url           = undef,
  Enum['apache'] $http_server  = 'apache',
) inherits ::role::appeng {

  class { '::profile::perl':
    mod_perl    => true,
    url         => $url,
    http_server => $http_server,
  }
}
