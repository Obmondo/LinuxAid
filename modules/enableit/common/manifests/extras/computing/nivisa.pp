# NI-VISA 2019
class common::extras::computing::nivisa (
  Boolean $enable = false,
) inherits ::common::extras::computing {

  confine($facts.dig('os', 'family') != 'RedHat',
    $facts.dig('os', 'release', 'major') != 7,
    'Only el7 supported')

  if $enable {
    profile::nivisa.include
  }

}
