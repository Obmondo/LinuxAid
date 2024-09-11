#
# == Class: freight::install
#
# Install freight
#
class freight::install inherits freight::params {

    package { 'freight-freight':
        ensure  => installed,
        name    => $::freight::params::package_name,
        require => Class['freight::aptrepo'],
    }

}
