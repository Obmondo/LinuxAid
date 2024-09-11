# @!visibility private
class rngd::params {

  case $::osfamily {
    'RedHat': {
      case $::operatingsystemmajrelease {
        '5': {
          # The package is different and lacks an init script on 5.x
          $package_name   = 'rng-utils'
          $service_manage = false
        }
        default: {
          $package_name   = 'rng-tools'
          $service_manage = true
        }
      }
      $hasstatus    = true
      $service_name = 'rngd'
    }
    'Debian': {
      $package_name   = 'rng-tools'
      $service_manage = true
      $service_name   = 'rng-tools'
      case $::operatingsystem {
        'Ubuntu': {
          case $::operatingsystemrelease {
            '12.04', '14.04': {
              $hasstatus = false
            }
            default: {
              $hasstatus = true
            }
          }
        }
        default: {
          case $::operatingsystemmajrelease {
            '6', '7': {
              $hasstatus = false
            }
            default: {
              $hasstatus = true
            }
          }
        }
      }
    }
    default: {
      fail("The ${module_name} module is not supported on an ${::osfamily} based system.")
    }
  }
}
