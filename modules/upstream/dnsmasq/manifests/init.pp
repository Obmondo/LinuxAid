class dnsmasq (
  Hash    $configs_hash     = {},
  Hash    $hosts_hash       = {},
  Hash    $dhcp_hosts_hash  = {},
  String  $package_ensure   = 'installed',
  Boolean $service_control  = true,
  Boolean $purge_config_dir = false,
) {
  include dnsmasq::params

  class { 'dnsmasq::install': }

  class { 'dnsmasq::config': require => Class['dnsmasq::install'], }

  class { 'dnsmasq::service':
    service_control => $service_control,
    subscribe       => Class['dnsmasq::install', 'dnsmasq::config'],
  }

  class { 'dnsmasq::reload':
    require => Class['dnsmasq::service'],
  }

  if $settings::storeconfigs {
    File_line <<| tag == 'dnsmasq-host' |>>
  }

  create_resources(dnsmasq::conf, $configs_hash)
  create_resources(dnsmasq::host, $hosts_hash)
  create_resources(dnsmasq::dhcp_host, $dhcp_hosts_hash)
}
