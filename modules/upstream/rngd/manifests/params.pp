# @!visibility private
class rngd::params {

  $package_name   = 'rng-tools'
  $service_manage = true

  case $facts['os']['family'] {
    'RedHat': {
      $hasstatus    = true
      $service_name = 'rngd'
    }
    'Debian': {
      $service_name = 'rng-tools'
      case $facts['os']['name'] {
        'Ubuntu': {
          case $facts['os']['release']['full'] {
            '14.04': {
              $hasstatus = false
            }
            default: {
              $hasstatus = true
            }
          }
        }
        default: {
          $hasstatus = true
        }
      }
    }
    default: {
      fail("The ${module_name} module is not supported on an ${facts['os']['family']} based system.")
    }
  }
}
