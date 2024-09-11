# Appeng CGI role
class role::appeng::cgi (
  Optional[URL] $url           = undef,
  Enum['apache'] $http_server  = 'apache',
) inherits ::role::appeng {

  class { '::profile::perl' :
    cgi         => true,
    url         => $url,
    http_server => $http_server,
  }
}
