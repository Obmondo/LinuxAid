# Class: bind::server
#
# For backwards compatibility. Use the main bind class instead.
#
class bind::server (
  $chroot            = false,
  $packagenameprefix = $::bind::params::packagenameprefix,
) inherits ::bind::params {

  class { '::bind':
    chroot            => $chroot,
    packagenameprefix => $packagenameprefix,
  }

}
