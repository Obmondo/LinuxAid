# memcached
class profile::memcached (
  Boolean      $memcached = true,
  Stdlib::Port $port      = 11211,
) {

  if $memcached {
    $ensure = 'present'
  } else {
    $ensure = 'absent'
  }

  case $facts['os']['family'] {
    'Debian' : { $user = 'memcache' }
    'RedHat' : { $user = 'memcached' }
    default  : { fail("${facts['os']['family']} is not supported") }
  }

  class { '::memcached' :
    package_ensure  => $ensure,
    max_connections => '4096',
    user            => $user,
    tcp_port        => $port,
  }
}
