
# @summary Class for managing the Appeng CGI role
#
# @param url The URL for the CGI application. Defaults to undef.
#
# @param http_server The HTTP server to use. Defaults to 'apache'.
#
class role::appeng::cgi (
  Optional[URL] $url           = undef,
  Enum['apache'] $http_server  = 'apache',
) inherits ::role::appeng {

  class { '::profile::perl':
    cgi         => true,
    url         => $url,
    http_server => $http_server,
  }
}
