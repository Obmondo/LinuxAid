#
# == Class: freight::params
#
# Defines some variables based on the operating system
#
class freight::params {

    include ::os::params

    case $::osfamily {
        'Debian': {
            $package_name = 'freight'
        }
        default: {
            fail("Unsupported OS: ${::osfamily}")
        }
    }
}
