# Bridge class
class bridge (
  $iname   = 'lxcbr0',
  $ports   = false,
  $fd      = '0',
  $maxwait = '0',
  $dhcp    = false,
  $address = '10.0.3.1',
  $netmask = '255.255.255.0',
  $gateway = undef,
  $up      = undef,
  $down    = undef,
  ) {

  if $dhcp and $address {
    fail('Conflicting options `dhcp` and `address`')
  }

  package {'bridge-utils':
    ensure => 'present',
  }

  $method = $dhcp ? {
    true    => 'dhcp',
    default => 'static',
  }

  case $facts['os']['family'] {
    'Debian': {
      augeas { 'Add source directive to interfaces':
        context => '/files/etc/network/interfaces',
        changes => [
                    'set source "/etc/network/interfaces.d/*"',
                    ],
        notify  => Service['networking'],
      }

      file { "/etc/network/interfaces.d/${iname}":
        ensure  => present,
        content => template('bridge/debian-if.conf.erb'),
        notify  => Service['networking'],
      }

      service { 'networking':
        ensure => running,
        enable => true,
      }


    }
    default: {
      fail("${facts['os']['family']} not supported")
    }
  }

}
