class dnsmasq::params {
  case $facts['os']['family'] {
    'Debian': {
      $package_name = 'dnsmasq'
      $service_name = 'dnsmasq'
      $config_file = '/etc/dnsmasq.conf'
      $resolv_file = '/etc/resolv.conf.dnsmasq'
      $config_dir = '/etc/dnsmasq.d/'
    }
    'RedHat': {
      $package_name = 'dnsmasq'
      $service_name = 'dnsmasq'
      $config_file = '/etc/dnsmasq.conf'
      $resolv_file = '/etc/resolv.conf.dnsmasq'
      $config_dir = '/etc/dnsmasq.d/'
    }
    default: {
      case $facts['os']['name'] {
        default: {
          fail("Unsupported platform: ${facts['os']['family']}/${facts['os']['name']}")
        }
      }
    }
  }
  $service_control = true
}
