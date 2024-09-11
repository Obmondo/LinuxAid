# Perl web role
class role::web::perl (
  Enum['::role::appeng::cgi', '::role::appeng::fastcgi', '::role::appeng::mod_perl']
    $variant = '::role::appeng::cgi',
) inherits role::web {

  class { $variant: }
}
