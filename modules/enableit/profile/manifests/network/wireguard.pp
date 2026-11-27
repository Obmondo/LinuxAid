# Wireguard
class profile::network::wireguard (
  Hash $tunnels = $common::network::wireguard::tunnels,
) {

  # We support both managed and unmanaged configuration. For managed
  # configuration we manage the WireGuard config file. For unmanaged we don't
  # manage the config file, but we do manage the service.
  #
  # For both managed and unmanaged we configure firewall.
  $_managed_tunnels = $tunnels.filter |$_key, $values| {
    $values.dig('manage_config').lest || { true }
  }
  $_unmanaged_tunnels = $tunnels - $_managed_tunnels

  $primary_iface = $facts['networking']['primary']

  # `networkctl reload` (below) reconfigures every link on systemd < 256, which
  # drops and re-acquires the primary interface's DHCP lease. This drop-in makes
  # networkd keep its address, lease and routes. The file name follows netplan.
  if !empty($_managed_tunnels) {
    file { "/etc/systemd/network/10-netplan-${primary_iface}.network.d":
      ensure => directory,
    }

    file { "/etc/systemd/network/10-netplan-${primary_iface}.network.d/keep.conf":
      ensure  => file,
      content => "[Network]\nKeepConfiguration=yes\n",
    }
  }

  $_managed_tunnels.each | $key, $value | {
    $_ensure = pick($value['ensure'], 'present')

    # networkd adds no routes for the peers' AllowedIPs, render one per range
    $_routes = $value['peers'].map |$_peer| {
      pick($_peer['allowed_ips'], [])
    }.flatten.unique.map |$_range| {
      { 'Destination' => $_range }
    }

    wireguard::interface { $key :
      ensure      => $_ensure,
      private_key => $value['private_key'],
      dport       => $value['listen_port'],
      addresses   => [{ 'Address' => $value['address'] }],
      routes      => $_routes,
      peers       => $value['peers'],
    }

    # The module never reloads networkd (needs systemd::manage_networkd), and
    # networkd ignores changes to an existing wireguard interface, so recreate it
    exec { "recreate wireguard interface ${key}":
      command     => "ip link delete dev ${key} 2>/dev/null; networkctl reload",
      path        => ['/usr/sbin', '/usr/bin', '/sbin', '/bin'],
      provider    => shell,
      refreshonly => true,
      subscribe   => Wireguard::Interface[$key],
      require     => File["/etc/systemd/network/10-netplan-${primary_iface}.network.d/keep.conf"],
    }

    # Clients reach what sits behind this host with its primary address
    firewall { "100 forward from ${key}":
      ensure  => $_ensure,
      chain   => 'FORWARD',
      proto   => 'all',
      iniface => $key,
      jump    => 'accept',
    }

    firewall { "100 nat postrouting ${key}":
      ensure   => $_ensure,
      table    => 'nat',
      chain    => 'POSTROUTING',
      proto    => 'all',
      source   => $value['address'],
      outiface => $primary_iface,
      jump     => 'MASQUERADE',
    }
  }

  $_unmanaged_tunnels.each |$key, $value| {
    file {"/etc/wireguard/${key}.conf":
      ensure => 'file',
      mode   => '0600',
      owner  => 'root',
      group  => 'root',
    }

    service {"wg-quick@${key}.service":
      ensure   => running,
      provider => 'systemd',
      enable   => true,
      require  => File["/etc/wireguard/${key}.conf"],
    }
  }

  $_ports = $tunnels.values.map |$_tunnel| {
    $_tunnel.dig('listen_port')
  }.delete_undef_values

  firewall_multi { "100 allow wireguard on ${_ports.join(' ')}":
    ensure => present,
    proto  => 'udp',
    dport  => $_ports.sort.unique,
    jump   => 'accept',
  }
}
