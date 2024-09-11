# Extra::Computing Class for things that does not classify into anything.
class common::extras::computing (
  Boolean $enable = false,
) inherits ::common::extras {

  if $enable {
    common::extras::computing::nivisa.include
  }

}
