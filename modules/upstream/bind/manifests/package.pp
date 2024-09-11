# Class: bind::package
#
class bind::package (
  $packagenameprefix = $::bind::params::packagenameprefix,
  $packagenamesuffix = '',
) inherits ::bind::params {

  package { "${packagenameprefix}${packagenamesuffix}": ensure => 'installed' }

}
