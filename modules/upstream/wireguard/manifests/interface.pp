#
# @summary manages a wireguard setup
#
# @param interface the title of the defined resource, will be used for the wg interface
# @param ensure will ensure that the files for the provider will be present or absent
# @param input_interface ethernet interface where the wireguard packages will enter the system, used for firewall rules
# @param manage_firewall if true, a nftables rule will be created
# @param dport destination for firewall rules / where our wg instance will listen on. defaults to the last digits from the title
# @param table Routing table to add routes to
# @param firewall_mark netfilter firewall mark to set on outgoing packages from this wireguard interface
# @param source_addresses an array of ip addresses from where we receive wireguard connections
# @param destination_addresses array of addresses where the remote peer connects to (our local ips), used for firewalling
# @param public_key base64 encoded pubkey from the remote peer
# @param endpoint fqdn:port or ip:port where we connect to
# @param addresses different addresses for the systemd-networkd configuration
# @param persistent_keepalive is set to 1 or greater, that's the interval in seconds wireguard sends a keepalive to the other peer(s). Useful if the sender is behind a NAT gateway or has a dynamic ip address
# @param description an optional string that will be added to the wireguard network interface
# @param mtu configure the MTU (maximum transision unit) for the wireguard tunnel. By default linux will figure this out. You might need to lower it if you're connection through a DSL line. MTU needs to be equal on both tunnel endpoints
# @param peers is an array of struct (Wireguard::Peers) for multiple peers
# @param routes different routes for the systemd-networkd configuration
# @param private_key Define private key which should be used for this interface, if not provided a private key will be generated
# @param preshared_key Define preshared key for the remote peer
# @param provider The specific backend to use for this `wireguard::interface` resource
# @param preup_cmds is an array of commands which should run as preup command (only supported by wgquick)
# @param postup_cmds is an array of commands which should run as preup command (only supported by wgquick)
# @param predown_cmds is an array of commands which should run as preup command (only supported by wgquick)
# @param postdown_cmds is an array of commands which should run as preup command (only supported by wgquick)
# @param endpoint_port optional outgoing port from the other endpoint. Will be used for firewalling. If not set, we will try to parse $endpoint
#
# @author Tim Meusel <tim@bastelfreak.de>
# @author Sebastian Rakel <sebastian@devunit.eu>
#
# @see https://www.freedesktop.org/software/systemd/man/systemd.netdev.html#%5BWireGuardPeer%5D%20Section%20Options
#
# @example Peer with one node and setup dualstack firewall rules
#  wireguard::interface {'as2273':
#    source_addresses => ['2003:4f8:c17:4cf::1', '149.9.255.4'],
#    public_key       => 'BcxLll1BVxGQ5DeijroesjroiesjrjvX+EBhS4vcDn0R0=',
#    endpoint         => 'wg.example.com:53668',
#    addresses        => [{'Address' => '192.168.123.6/30',},{'Address' => 'fe80::beef:1/64'},],
#  }
#
# @example Peer with one node and setup dualstack firewall rules with peers in a different layer2
#  wireguard::interface {'as2273':
#    source_addresses => ['2003:4f8:c17:4cf::1', '149.9.255.4'],
#    public_key       => 'BcxLll1BVxGQ5DeijroesjroiesjrjvX+EBhS4vcDn0R0=',
#    endpoint         => 'wg.example.com:53668',
#    addresses        => [{'Address' => '192.168.218.87/32', 'Peer' => '172.20.53.97/32'}, {'Address' => 'fe80::ade1/64',},],
#  }
#
# @example Create a passive wireguard interface that listens for incoming connections. Useful when the other side has a dynamic IP / is behind NAT
#  wireguard::interface {'as2273':
#    source_addresses => ['2003:4f8:c17:4cf::1', '149.9.255.4'],
#    public_key       => 'BcxLll1BVxGQ5DeijroesjroiesjrjvX+EBhS4vcDn0R0=',
#    dport            => 53668,
#    addresses        => [{'Address' => '192.168.218.87/32', 'Peer' => '172.20.53.97/32'}, {'Address' => 'fe80::ade1/64',},],
#  }
#
# @example create a wireguard interface behind a DSL line with changing IP with lowered MTU
#  wireguard::interface {'as3668-2':
#    source_addresses      => ['144.76.249.220', '2a01:4f8:171:1152::12'],
#    public_key            => 'Tci/bHoPCjTpYv8bw17xQ7P4OdqzGpEN+NDueNjUvBA=',
#    endpoint              => 'router02.bastelfreak.org:1338',
#    dport                 => 1338,
#    input_interface       => $facts['networking']['primary'],
#    addresses             => [{'Address' => '169.254.0.10/32', 'Peer' =>'169.254.0.9/32'},{'Address' => 'fe80::beef:f/64'},],
#    destination_addresses => [],
#    persistent_keepalive  => 5,
#    mtu                   => 1412,
# }
#
# @example create a wireguard interface with multiple peers where one uses a preshared key
#  wireguard::interface { 'wg0':
#    dport     => 1338,
#    addresses => [{'Address' => '192.0.2.1/24'}],
#    peers     => [
#      {
#         public_key  => 'foo==',
#         preshared_key => '/22q9I+RpWRsU+zshW8skv1p00TvnEE6fTvPJuI2Cp4=',
#         allowed_ips => ['192.0.2.2'],
#      },
#      {
#         public_key  => 'bar==',
#         allowed_ips => ['192.0.2.3'],
#      }
#    ],
#  }
#
# @example create two sides of a session using the public key from the other side
#  wireguard::interface { 'wg0':
#    source_addresses => ['2003:4f8:c17:4cf::1', '149.9.255.4'],
#    public_key       => $facts['wireguard_pubkeys']['nodeB'],
#    endpoint         => 'nodeB.example.com:53668',
#    addresses        => [{'Address' => '192.168.123.6/30',},{'Address' => 'fe80::beef:1/64'},],
#  }
#
define wireguard::interface (
  Enum['present', 'absent'] $ensure = 'present',
  Wireguard::Peers $peers = [],
  Optional[String[1]] $endpoint = undef,
  Integer[0, 65535] $persistent_keepalive = 0,
  Array[Stdlib::IP::Address] $destination_addresses = delete_undef_values([$facts['networking']['ip'], $facts['networking']['ip6'],]),
  String[1] $interface = $title,
  Integer[1024, 65000] $dport = Integer(regsubst($title, '^\D+(\d+)$', '\1')),
  Optional[String[1]] $table = undef,
  Optional[Integer[0, 4294967295]] $firewall_mark = undef,
  String[1] $input_interface = $facts['networking']['primary'],
  Boolean $manage_firewall = $facts['os']['family'] ? { 'Gentoo' => false, default => true },
  Array[Stdlib::IP::Address] $source_addresses = [],
  Array[Hash[String,Variant[Stdlib::IP::Address::V4,Stdlib::IP::Address::V6]]] $addresses = [],
  Optional[String[1]] $description = undef,
  Optional[Integer[1200, 9000]] $mtu = undef,
  Optional[String[1]] $public_key = undef,
  Array[Hash[String[1], Variant[String[1], Boolean]]] $routes = [],
  Optional[String[1]] $private_key = undef,
  Optional[String[1]] $preshared_key = undef,
  Enum['systemd', 'wgquick'] $provider = 'systemd',
  Array[String[1]] $preup_cmds = [],
  Array[String[1]] $postup_cmds = [],
  Array[String[1]] $predown_cmds = [],
  Array[String[1]] $postdown_cmds = [],
  Optional[Stdlib::Port] $endpoint_port = undef,
) {
  include wireguard

  if empty($peers) and !$public_key {
    warning('peers or public_key have to been set')
  }

  $_endpoint_port = if $endpoint_port {
    $endpoint_port
  } elsif ($endpoint and $endpoint =~ /:(\d+)$/) {
    Integer($1)
  } else {
    undef
  }
  if $manage_firewall {
    $source_addresses.each |$index1, $saddr| {
      if $saddr =~ Stdlib::IP::Address::V4 {
        if empty($destination_addresses) {
          nftables::simplerule { "allow_in_wg_${interface}-${index1}":
            action  => 'accept',
            comment => "Allow traffic from interface ${input_interface} from IP ${saddr} for wireguard tunnel ${interface}",
            dport   => $dport,
            sport   => $_endpoint_port,
            proto   => 'udp',
            saddr   => $saddr,
            iifname => $input_interface,
            notify  => Service['systemd-networkd'],
          }
          nftables::simplerule { "allow_out_wg_${interface}-${index1}":
            action  => 'accept',
            comment => "Allow traffic out interface ${input_interface} to IP ${saddr} for wireguard tunnel ${interface}",
            dport   => $_endpoint_port,
            sport   => $dport,
            proto   => 'udp',
            daddr   => $saddr,
            oifname => $input_interface,
            chain   => 'default_out',
            notify  => Service['systemd-networkd'],
          }
        } else {
          $destination_addresses.each |$index2, $_daddr| {
            if $_daddr =~ Stdlib::IP::Address::V4 {
              nftables::simplerule { "allow_in_wg_${interface}-${index1}${index2}":
                action  => 'accept',
                comment => "Allow traffic from interface ${input_interface} from IP ${saddr} for wireguard tunnel ${interface}",
                dport   => $dport,
                sport   => $_endpoint_port,
                proto   => 'udp',
                daddr   => $_daddr,
                saddr   => $saddr,
                iifname => $input_interface,
                notify  => Service['systemd-networkd'],
              }
              nftables::simplerule { "allow_out_wg_${interface}-${index1}${index2}":
                action  => 'accept',
                comment => "Allow traffic out interface ${input_interface} to IP ${saddr} for wireguard tunnel ${interface}",
                dport   => $_endpoint_port,
                sport   => $dport,
                proto   => 'udp',
                daddr   => $saddr,
                saddr   => $_daddr,
                oifname => $input_interface,
                chain   => 'default_out',
                notify  => Service['systemd-networkd'],
              }
            }
          }
        }
      } else {
        if empty($destination_addresses) {
          nftables::simplerule { "allow_in_wg_${interface}-${index1}":
            action  => 'accept',
            comment => "Allow traffic from interface ${input_interface} from IP ${saddr} for wireguard tunnel ${interface}",
            dport   => $dport,
            sport   => $_endpoint_port,
            proto   => 'udp',
            saddr   => $saddr,
            iifname => $input_interface,
            notify  => Service['systemd-networkd'],
          }
          nftables::simplerule { "allow_out_wg_${interface}-${index1}":
            action  => 'accept',
            comment => "Allow traffic out interface ${input_interface} to IP ${saddr} for wireguard tunnel ${interface}",
            dport   => $_endpoint_port,
            sport   => $dport,
            proto   => 'udp',
            daddr   => $saddr,
            oifname => $input_interface,
            chain   => 'default_out',
            notify  => Service['systemd-networkd'],
          }
        } else {
          $destination_addresses.each |$index2, $_daddr| {
            if $_daddr =~ Stdlib::IP::Address::V6 {
              nftables::simplerule { "allow_in_wg_${interface}-${index1}${index2}":
                action  => 'accept',
                comment => "Allow traffic from interface ${input_interface} from IP ${saddr} for wireguard tunnel ${interface}",
                dport   => $dport,
                sport   => $_endpoint_port,
                proto   => 'udp',
                daddr   => $_daddr,
                saddr   => $saddr,
                iifname => $input_interface,
                notify  => Service['systemd-networkd'],
              }
              nftables::simplerule { "allow_out_wg_${interface}-${index1}${index2}":
                action  => 'accept',
                comment => "Allow traffic out interface ${input_interface} to IP ${saddr} for wireguard tunnel ${interface}",
                dport   => $_endpoint_port,
                sport   => $dport,
                proto   => 'udp',
                daddr   => $saddr,
                saddr   => $_daddr,
                oifname => $input_interface,
                chain   => 'default_out',
                notify  => Service['systemd-networkd'],
              }
            }
          }
        }
      }
    }
  }

  $private_key_path = "${wireguard::config_directory}/${interface}"

  if $private_key {
    file { $private_key_path:
      ensure  => 'file',
      content => $private_key,
      owner   => 'root',
      group   => 'systemd-network',
      mode    => '0640',
      notify  => Exec["generate public key ${interface}"],
    }
  } else {
    exec { "generate private key ${interface}":
      command => "wg genkey > ${interface}",
      cwd     => $wireguard::config_directory,
      creates => $private_key_path,
      path    => '/usr/bin',
      before  => File[$private_key_path],
      notify  => Exec["generate public key ${interface}"],
    }

    file { $private_key_path:
      ensure => 'file',
      owner  => 'root',
      group  => 'systemd-network',
      mode   => '0640',
    }
  }

  exec { "generate public key ${interface}":
    command => "wg pubkey < ${interface} > ${interface}.pub",
    cwd     => $wireguard::config_directory,
    creates => "${wireguard::config_directory}/${interface}.pub",
    path    => '/usr/bin',
  }

  file { "${wireguard::config_directory}/${interface}.pub":
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    require => Exec["generate public key ${interface}"],
  }

  if $public_key {
    $peer = [{
        public_key           => $public_key,
        endpoint             => $endpoint,
        preshared_key        => $preshared_key,
        persistent_keepalive => $persistent_keepalive,
    }]
  } else {
    $peer = []
  }

  case $provider {
    'systemd': {
      if !empty($preup_cmds) {
        warning('PreUp commands are not supported by systemd-networkd')
      }

      if !empty($postup_cmds) {
        warning('PostUp commands are not supported by systemd-networkd')
      }

      if !empty($predown_cmds) {
        warning('PreDown commands are not supported by systemd-networkd')
      }

      if !empty($postdown_cmds) {
        warning('PostDown commands are not supported by systemd-networkd')
      }

      wireguard::provider::systemd { $interface :
        ensure            => $ensure,
        interface         => $interface,
        peers             => $peers + $peer,
        dport             => $dport,
        firewall_mark     => $firewall_mark,
        addresses         => $addresses,
        description       => $description,
        mtu               => $mtu,
        routes            => $routes,
        default_allowlist => $wireguard::default_allowlist,
      }
    }
    'wgquick': {
      wireguard::provider::wgquick { $interface :
        ensure            => $ensure,
        interface         => $interface,
        peers             => $peers + $peer,
        dport             => $dport,
        table             => $table,
        firewall_mark     => $firewall_mark,
        addresses         => $addresses,
        preup_cmds        => $preup_cmds,
        postup_cmds       => $postup_cmds,
        predown_cmds      => $predown_cmds,
        postdown_cmds     => $postdown_cmds,
        mtu               => $mtu,
        default_allowlist => $wireguard::default_allowlist,
      }
    }
    default: {
      fail("provider ${provider} not supported")
    }
  }
}
