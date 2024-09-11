# Appeng passenger role
class role::appeng::passenger (
  Eit_types::URL $url              = undef,
  Enum['4', '5'] $version          = '5',
  Enum['gem', 'package'] $provider = 'package',
  Enum['apache'] $http_server      = 'apache',
  Boolean $manage_web_server       = false
) inherits ::role::appeng {
  class { '::profile::passenger' :
    url                => $url,
    http_server        => $http_server,
    passenger_version  => $version,
    passenger_provider => $provider,
    manage_web_server  => $manage_web_server
  }
}
