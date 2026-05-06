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

  $_managed_tunnels.each | $key, $value | {

    # 1. Dynamically figure out the public interface for this specific server
    $primary_iface = $facts['networking']['primary']

    # 2. Define the default NAT/Routing commands 
    $default_postup = [
      "iptables -A FORWARD -i ${key} -j ACCEPT",
      "iptables -t nat -A POSTROUTING -o ${primary_iface} -j MASQUERADE"
    ]

    $default_postdown = [
      "iptables -D FORWARD -i ${key} -j ACCEPT",
      "iptables -t nat -D POSTROUTING -o ${primary_iface} -j MASQUERADE"
    ]

    wireguard::interface  { $key :
      ensure      => pick($value['ensure'], 'present'),
      private_key => $value['private_key'],
      dport       => $value['listen_port'],
      addresses   => [{'address' => $value['address']}],
      peers       => $value['peers'],
      provider    => pick($value['provider'], 'wgquick'),
      postup_cmds   => pick($value['postup_cmds'], $default_postup),
      postdown_cmds => pick($value['postdown_cmds'], $default_postdown),
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
