
# summary Class for managing the Appeng fastcgi role
#
# @param url The URL for the fastcgi application. Defaults to undef.
#
# @groups server url
#
class role::appeng::fastcgi (
  Eit_types::URL $url = undef,
) inherits ::role::appeng {

  class { '::profile::web::perl':
    fastcgi     => true,
    url         => $url,
    http_server => 'apache',
  }
}
