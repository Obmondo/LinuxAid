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

    $_ensure   = pick($value['ensure'], 'present')
    $_provider = pick($value['provider'], 'wgquick')

    wireguard::interface  { $key :
      ensure        => $_ensure,
      private_key   => $value['private_key'],
      dport         => $value['listen_port'],
      addresses     => [{'Address' => $value['address']}],
      peers         => $value['peers'],
      provider      => $_provider,
      postup_cmds   => pick($value['postup_cmds'], $default_postup),
      postdown_cmds => pick($value['postdown_cmds'], $default_postdown),
    }

    if $_provider == 'wgquick' {
      # 3. The wgquick provider only writes the config file, so the service
      # that brings the tunnel up (and applies a changed config) is managed here
      if $_ensure == 'present' {
        service { "wg-quick@${key}.service":
          ensure    => running,
          provider  => 'systemd',
          enable    => true,
          subscribe => Wireguard::Interface[$key],
        }
      } else {
        # wg-quick needs the config file to take the tunnel down
        service { "wg-quick@${key}.service":
          ensure   => stopped,
          provider => 'systemd',
          enable   => false,
          before   => Wireguard::Interface[$key],
        }
      }

      # 4. Hosts first set up with the systemd provider keep its networkd files.
      # networkd then creates the interface at boot, without an address, and
      # wg-quick fails to start because the interface already exists
      file { ["/etc/systemd/network/${key}.netdev", "/etc/systemd/network/${key}.network"]:
        ensure => absent,
        notify => Exec["remove networkd owned wireguard interface ${key}"],
      }

      exec { "remove networkd owned wireguard interface ${key}":
        command     => "networkctl reload; ip link delete dev ${key}",
        onlyif      => "ip link show dev ${key}",
        unless      => "systemctl is-active --quiet wg-quick@${key}.service",
        path        => ['/usr/sbin', '/usr/bin', '/sbin', '/bin'],
        provider    => shell,
        refreshonly => true,
        before      => Service["wg-quick@${key}.service"],
      }
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
