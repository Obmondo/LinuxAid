# handle installation of passenger from gem
class passenger::gems (
  $passenger_version = 'present'
  ) {

  if versioncmp ($passenger_version, '4.0.0') > 0 {
    $builddir     = 'buildout'
  } else {
    $builddir     = 'ext'
  }

  case $facts['os']['family'] {
    'Debian': {
      case $facts['os']['release']['major'] {
        '14.04' : {
          $real_gem_path        = '/var/lib/gems/1.9.1/gems'
          $real_passenger_root  = "${real_gem_path}/passenger-${passenger_version}"
          $real_mod_passenger   = "${real_passenger_root}/${builddir}/apache2/mod_passenger.so"
        }
        #TODO support debian jessie
        default : {
          $real_gem_path        = '/var/lib/gems/1.8/gems'
          $real_passenger_root  = "${real_gem_path}/passenger-${passenger_version}"
          $real_mod_passenger   = "${real_passenger_root}/${builddir}/apache2/mod_passenger.so"
        }
      }

      # Get the real values
      $gem_path       = $real_gem_path
      $passenger_root = $real_passenger_root
      $mod_passenger  = $real_mod_passenger

      # Ubuntu does not have libopenssl-ruby - it's packaged in libruby
      if $facts['os']['distro']['id'] == 'Debian' and $::operatingsystemmajrelese <= 5 {
        $package_dependencies01   = [ 'libopenssl-ruby', 'libcurl4-openssl-dev' ]
      } else {
        $package_dependencies01   = [ 'libruby', 'libcurl4-openssl-dev' ]
      }

      $package_dependencies02 = [ 'build-essential', 'apache2-threaded-dev', 'libapr1-dev', 'libaprutil1-dev' ]

      # Merge both the arrays
      $package_dependencies = concat($package_dependencies01, $package_dependencies02)

      # Install dependencies packages
      stdlib::ensure_packages($package_dependencies)
    }
    'RedHat': {
      case $facts['os']['release']['major'] {
        '6' : {
          $real_gem_path               = '/usr/lib/ruby/gems/1.8/gems'
          $real_passenger_root         = "${real_gem_path}/passenger-${passenger_version}"
          $real_mod_passenger_location = "${real_passenger_root}/${builddir}/apache2/mod_passenger.so"
        }
        '7' : {
          $real_gem_path               = '/usr/local/share/gems/gems'
          $real_passenger_root         = "${real_gem_path}/passenger-${passenger_version}"
          $real_mod_passenger_location = "${real_passenger_root}/${builddir}/apache2/mod_passenger.so"
        }
        default : { fail('Not Supported') }
      }
      $package_dependencies   = [
        'gcc',
        'gcc-c++' ,
        'curl-devel',
        'openssl-devel',
        'zlib-devel',
        'httpd-devel',
        'apr-devel',
        'apr-util-devel',
        'make',
        'ruby-devel',
      ]
      $gem_path               = $real_gem_path
      $gem_binary_path        = "${real_gem_path}/bin"
      $passenger_root         = $real_passenger_root
      $mod_passenger          = $real_mod_passenger_location

      # Install development packages
      stdlib::ensure_packages($package_dependencies)
    }
    default: {
      fail("Operating system ${facts['os']['family']} is not supported with the Passenger module")
    }
  }
}
