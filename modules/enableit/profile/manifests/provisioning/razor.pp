# razor
class profile::provisioning::razor (
  Boolean                       $manage_postgres = $role::provisioning::razor::manage_postgres,
  Eit_types::Host               $db_server       = $role::provisioning::razor::db_server,
  Eit_types::SimpleString       $db_name         = $role::provisioning::razor::db_name,
  Eit_types::SimpleString       $db_user         = $role::provisioning::razor::db_user,
  Eit_types::Password           $db_password     = $role::provisioning::razor::db_password,
  Eit_types::IP                 $dhcp_start      = $role::provisioning::razor::dhcp_start,
  Eit_types::IP                 $dhcp_end        = $role::provisioning::razor::dhcp_end,
  Eit_types::IP                 $dhcp_route      = $role::provisioning::razor::dhcp_route,
  Array[Eit_types::IP, 1]       $dhcp_dns        = $role::provisioning::razor::dhcp_dns,
  Eit_types::Domain             $dhcp_domain     = $role::provisioning::razor::dhcp_domain,
  Boolean                       $manage_tftpd    = $role::provisioning::razor::manage_tftpd,
) inherits ::profile {

  $_base_path = '/opt/obmondo/razor'

  $_additional_brokers = [
    "${_base_path}/brokers",
  ]
  $_additional_hooks = [
    "${_base_path}/hooks",
  ]
  $_additional_tasks = [
    "${_base_path}/tasks",
  ]

  file { '/opt/obmondo/razor' :
    ensure  => directory,
    source  => 'puppet:///modules/profile/provisioning/razor',
    recurse => true,
    purge   => true,
    ignore  => '*~',
    before  => Class['razor'],
  }

  file { '/opt/obmondo/razor/brokers/enableit.broker/install.erb':
    ensure  => present,
    content => epp('profile/provisioning/install.epp', {
      'customerid' => $facts.dig('obmondo', 'customerid'),
    }),
    before  => Class['razor'],
  }

  class { 'razor':
    manage_postgres    => $manage_postgres,
    db_server          => $db_server,
    db_name            => $db_name,
    db_user            => $db_user,
    db_password        => $db_password,
    additional_brokers => $_additional_brokers,
    additional_hooks   => $_additional_hooks,
    additional_tasks   => $_additional_tasks,
  }

  $dhcp_range = "${dhcp_start},${dhcp_end}"
  $dhcp_dns_servers = join($dhcp_dns, ',')

  file { '/etc/dnsmasq.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp('profile/provisioning/dnsmasq.conf.epp', {
      'dhcp_range'       => $dhcp_range,
      'dhcp_router'      => $dhcp_route,
      'dhcp_dns_servers' => $dhcp_dns_servers,
      'domain'           => $dhcp_domain,
      'interface'        => $facts['networking']['interfaces']['primary_interface']['network'],
    }),
  }

  firewall_multi { '200 allow razor server':
    dport => 8150,
    proto => 'tcp',
    jump  => 'accept',
  }

  firewall_multi { '200 allow dnsmasq server':
    dport => [67, 69],
    proto => 'udp',
    jump  => 'accept',
  }
}
