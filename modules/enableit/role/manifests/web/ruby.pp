# Web Ruby Role
class role::web::ruby (
  Enum['::role::appeng::passenger'] $variant = '::role::appeng::passenger',
) inherits role::web {

  class { $variant: }
}
