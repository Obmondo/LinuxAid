
# @summary Class for managing the Appeng CGI role
#
# @param url The URL for the CGI application. Defaults to undef.
#
# @groups server url
#
class role::appeng::cgi (
  Optional[URL] $url = undef,
) inherits ::role::appeng {

  class { '::profile::web::perl':
    cgi         => true,
    url         => $url,
    http_server => 'apache',
  }
}
