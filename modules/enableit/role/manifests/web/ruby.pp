
# @summary Class for managing the Web Ruby role
#
# @param variant The variant of the application engine to use. Defaults to '::role::appeng::passenger'.
#
# @groups variant variant
#
class role::web::ruby (
  Enum['::role::appeng::passenger'] $variant = '::role::appeng::passenger',
) inherits role::web {

  class { $variant: }
}
