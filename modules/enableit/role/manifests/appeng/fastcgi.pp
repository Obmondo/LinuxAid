# Appeng fastcgi role
class role::appeng::fastcgi (
  Eit_types::URL $url         = undef,
  Enum['apache'] $http_server = 'apache',
) inherits ::role::appeng {

  class { '::profile::perl':
    fastcgi     => true,
    url         => $url,
    http_server => $http_server,
  }
}
