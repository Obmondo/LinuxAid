
# @summary Class for managing the Mod Perl role
#
# @param url The URL for the application. Defaults to undef.
#
# @groups server url
#
class role::appeng::mod_perl (
  Optional[Eit_types::URL] $url = undef,
) inherits ::role::appeng {

  class { '::profile::web::perl':
    mod_perl    => true,
    url         => $url,
    http_server => 'apache',
  }
}
