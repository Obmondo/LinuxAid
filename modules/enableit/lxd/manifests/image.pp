# Setup the images repos
class lxd::image {
  exec { 'create_lxd_default_image_repository' :
    command   => '/usr/bin/lxc remote add lxd-images https://images.linuxcontainers.org',
    unless    => '/usr/bin/lxc remote list | grep lxd-images >/dev/null 2>&1',
    logoutput => true,
    require   => Package['lxd-client'],
  }
}
