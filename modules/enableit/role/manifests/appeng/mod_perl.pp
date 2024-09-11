# Mod Perl role
class role::appeng::mod_perl (
  Optional[Eit_types::URL] $url = undef,
  Enum['apache'] $http_server   = 'apache',
) inherits ::role::appeng {

  class { '::profile::perl' :
    mod_perl    => true,
    url         => $url,
    http_server => $http_server,
  }
}
