# Web PHP role
class role::web::php (
  Enum['::role::appeng::mod_php', '::role::appeng::phpfpm']
    $variant = '::role::appeng::phpfpm',
) inherits role::web {

  class { $variant: }

}
