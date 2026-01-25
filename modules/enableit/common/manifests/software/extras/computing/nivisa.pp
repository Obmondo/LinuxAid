# @summary Class for managing NI-VISA 2019 configuration
#
# @param enable Boolean flag to enable or disable NI-VISA. Defaults to false.
#
# @groups enable enable
#
class common::extras::computing::nivisa (
  Boolean $enable = false,
) inherits ::common::extras::computing {
  confine($facts['os']['family'] != 'RedHat',
          $facts['os']['release']['major'] != 7,
          'Only el7 supported')
  if $enable {
    profile::nivisa.include
  }
}
