
# summary Class for managing the Appeng fastcgi role
#
# @param url The URL for the fastcgi application. Defaults to undef.
#
# @param http_server The HTTP server to use. Defaults to 'apache'.
#
# @groups server url, http_server
#
class role::appeng::fastcgi (
  Eit_types::URL $url         = undef,
  Enum['apache'] $http_server  = 'apache',
) inherits ::role::appeng {

  class { '::profile::perl':
    fastcgi     => true,
    url         => $url,
    http_server => $http_server,
  }
}
