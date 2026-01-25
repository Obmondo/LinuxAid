# @summary Class for things that does not classify into anything
#
# @param manage Boolean parameter to determine if computing management should be included. Defaults to false.
#
# @groups management manage
#
class common::extras (
  Boolean $manage = false,
) inherits ::common {
  if $manage {
    common::extras::computing.include
  }
}
