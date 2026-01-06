# @summary Class for extra computing-related functionalities that do not fall into other categories
#
# @param enable Boolean to enable computing extras. Defaults to false.
#
# @groups settings enable
#
class common::extras::computing (
  Boolean $enable = false,
) inherits ::common::extras {

  if $enable {
    common::extras::computing::nivisa.include
  }

}
