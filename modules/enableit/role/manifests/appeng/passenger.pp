
# @summary Class for managing the Appeng passenger role
#
# @param url The URL for the passenger application. Defaults to undef.
#
# @param version The version of the passenger to use. Defaults to '5'.
#
# @param provider The provider type for passenger. Defaults to 'package'.
#
# @param http_server The HTTP server to use. Defaults to 'apache'.
#
# @param manage_web_server A boolean to manage the web server. Defaults to false.
#
# @groups server url, http_server, manage_web_server
#
# @groups passenger version, provider
#
class role::appeng::passenger (
  Eit_types::URL $url              = undef,
  Enum['4', '5'] $version          = '5',
  Enum['gem', 'package'] $provider  = 'package',
  Enum['apache'] $http_server      = 'apache',
  Boolean $manage_web_server       = false,
) inherits ::role::appeng {

  class { '::profile::passenger':
    url                => $url,
    http_server        => $http_server,
    passenger_version  => $version,
    passenger_provider => $provider,
    manage_web_server  => $manage_web_server
  }
}
