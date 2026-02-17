# @summary Class for managing NI-VISA 2019 configuration
#
# @param manage Whether to manage the NI-VISA configuration. Defaults to false.
#
# @param enable Boolean flag to enable or disable NI-VISA. Defaults to false.
#
# @groups settings manage, enable
#
class common::software::nivisa (
  Boolean $manage = false,
  Boolean $enable = false,
) {
  confine($facts['os']['family'] != 'RedHat',
          $facts['os']['release']['major'] != 7,
          'Only el7 supported')
  if $enable {
    profile::nivisa.include
  }
}
