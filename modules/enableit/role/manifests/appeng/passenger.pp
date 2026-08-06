
# @summary Class for managing the Appeng passenger role
#
# @param url The URL for the passenger application. Defaults to undef.
#
# @param version The version of the passenger to use. Defaults to '5'.
#
# @param provider The provider type for passenger. Defaults to 'package'.
#
# @groups server url
#
# @groups passenger version, provider
#
class role::appeng::passenger (
  Eit_types::URL $url              = undef,
  Enum['4', '5'] $version          = '5',
  Enum['gem', 'package'] $provider = 'package',
) inherits ::role::appeng {

  class { '::profile::appeng::passenger':
    url                => $url,
    http_server        => 'apache',
    passenger_version  => $version,
    passenger_provider => $provider,
    manage_web_server  => false
  }
}
