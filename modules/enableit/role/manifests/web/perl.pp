
# @summary Class for managing the Perl web role
#
# @param variant The variant of the Appeng application to use. Defaults to '::role::appeng::cgi'.
#
class role::web::perl (
  Enum['::role::appeng::cgi', '::role::appeng::fastcgi', '::role::appeng::mod_perl'] $variant = '::role::appeng::cgi',
) inherits role::web {

  class { $variant: }
}
