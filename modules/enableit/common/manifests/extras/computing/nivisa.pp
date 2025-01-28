# NI-VISA 2019
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
