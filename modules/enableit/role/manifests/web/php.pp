
# @summary Class for managing the Web PHP role
#
# @param variant The PHP variant to use. Defaults to '::role::appeng::phpfpm'.
#
class role::web::php (
  Enum['::role::appeng::mod_php', '::role::appeng::phpfpm'] $variant = '::role::appeng::phpfpm',
) inherits role::web {

  class { $variant: }
}
