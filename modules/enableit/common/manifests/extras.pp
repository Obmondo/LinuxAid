# Extra Class for things that does not classify into anything.
class common::extras (
  Boolean $manage = false,
) inherits ::common {

  if $manage {
    common::extras::computing.include
  }

}
