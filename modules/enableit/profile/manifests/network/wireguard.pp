# Wireguard
class profile::network::wireguard (
  Hash $tunnels = $common::network::wireguard::tunnels,
) {

  $_manage_repo = $::facts['os']['name'] ? {
    'Ubuntu' => false,
    default  => true
  }

  class { '::wireguard':
    manage_repo => $_manage_repo
  }

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
    wireguard::interface { $key :
      ensure      => pick($value['ensure'], 'present'),
      private_key => $value['private_key'],
      listen_port => $value['listen_port'],
      address     => $value['address'],
      saveconfig  => false,
      peers       => $value['peers']
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
