# Firewall
class profile::network::firewall (
  Boolean             $enable            = $common::network::firewall::enable,
  Boolean             $enable_ipv6       = $common::network::firewall::enable_ipv6,
  Boolean             $enable_forwarding = $common::network::firewall::enable_forwarding,
  Boolean             $drop_all          = $common::network::firewall::drop_all,
  Std_fw::Action      $drop_action       = $common::network::firewall::drop_action,
  Boolean             $allow_docker      = $common::network::firewall::allow_docker,
  Boolean             $allow_k8s         = $common::network::firewall::allow_docker,
  Boolean             $allow_azure       = $common::network::firewall::allow_azure,
  Boolean             $allow_netbird     = $common::network::firewall::allow_netbird,

  Boolean             $block_bogons            = $common::network::firewall::block_bogons,
  Boolean             $block_mdns              = $common::network::firewall::block_mdns,
  Boolean             $block_kaspersky_sccc    = $common::network::firewall::block_kaspersky_sccc,
  Boolean             $block_hasp_lm           = $common::network::firewall::block_hasp_lm,
  Boolean             $block_dhcp_broadcast    = $common::network::firewall::block_dhcp_broadcast,
  Boolean             $block_netbios_broadcast = $common::network::firewall::block_netbios_broadcast,

  Eit_types::Firewall $rules = $common::network::firewall::rules,
) {

  class { 'firewall':
    ensure    => $enable.ensure_service,
    ensure_v6 => $enable_ipv6.ensure_service,
  }

  Firewall {
    before  => Class['std_fw::post'],
    require => Class['std_fw::pre'],
  }

  class { 'std_fw::pre': }
  class { 'std_fw::post':
    drop_all => $drop_all,
  }

  # Forwarding rules
  [
    'iptables',
    if $enable_ipv6 { 'ip6tables' },
  ].delete_undef_values.each |$_protocol| {
    $_title = if $enable_forwarding { 'enable' } else { 'disable' }
    $_ip_version = $_protocol ? {
      'iptables' => 'IPv4',
      'ip6tables' => 'IPv6',
    }

    firewall {"100 forwarding ${_title} ${_ip_version}":
      ensure   => 'present',
      chain    => 'FORWARD',
      jump     => if $enable_forwarding { 'accept' } else { 'reject' },
      proto    => 'all',
      reject   => if $drop_action == 'reject' and !$enable_forwarding {
        $_protocol ? {
          'iptables'  => 'icmp-host-prohibited',
          'ip6tables' => 'icmp6-adm-prohibited',
        }
      },
      table    => 'filter',
      protocol => $_protocol,
    }
  }

  if $allow_docker or $allow_k8s or $allow_azure or $allow_netbird {
    # This is to support a more relaxed firewall setup, where only
    # INPUT, FORWARD and OUTPUT chains are purged/managed
    # and docker inserted rules are ignored
    resources { 'firewall':
      purge => false,
    }

    $_input = [
      if $allow_k8s { [
        'KUBE-EXTERNAL-SERVICES',
        'cali-INPUT',
        'KUBE-PROXY-FIREWALL',
        'KUBE-NODEPORTS',
      ] }
    ].flatten.delete_undef_values

    $_output = [
      if $allow_k8s { [
        'cali-OUTPUT',
        'KUBE-SERVICES',
        'CNI-HOSTPORT-DNAT',
        'KUBE-PROXY-FIREWALL',
        'KUBE-NODEPORTS',
      ] }
    ].flatten.delete_undef_values

    $_forward = [
      if $allow_docker { ['DOCKER', 'docker0', '-o br-'] },
      if $allow_k8s { [
        'cali-FORWARD',
        'KUBE-FORWARD',
        'KUBE-SERVICES',
        'KUBE-EXTERNAL-SERVICES',
        'KUBE-PROXY-FIREWALL',
        '--comment "cali:*',
      ] },
      if $allow_netbird { [ 'NETBIRD-RT-FWD' ] },
    ].flatten.delete_undef_values

    $_prerouting = [
      if $allow_docker { ['DOCKER'] },
      if $allow_k8s { ['cali-PREROUTING', 'KUBE-SERVICES', 'CNI-HOSTPORT-DNAT'] },
    ].flatten.delete_undef_values

    $_postrouting = [
      if $allow_docker { ['docker', '172', '-o br-', '192.168'] },
      if $allow_k8s { ['cali-POSTROUTING', 'CNI-HOSTPORT-MASQ', 'KUBE-POSTROUTING'] },
      if $allow_netbird { [ 'NETBIRD-RT-NAT' ] },
    ].flatten.delete_undef_values

    # Flush INPUT and OUTPUT chains
    firewallchain { 'INPUT:filter:IPv4':
      ensure => present,
      purge  => true,
      ignore => $_input,
    }

    firewallchain { 'OUTPUT:filter:IPv4':
      ensure => present,
      purge  => true,
      ignore => $_output,
    }

    # Leave DOCKER managed firewall configuration alone
    # NOTES: '-j DOCKER' didn't worked in testing
    # to ignore the iptables rule for docker and docker-compose
    firewallchain { 'FORWARD:filter:IPv4':
      purge  => true,
      ignore => $_forward,
    }

    firewallchain { 'POSTROUTING:nat:IPv4':
      purge  => true,
      ignore => $_postrouting,
    }

    firewallchain { 'PREROUTING:nat:IPv4':
      purge  => true,
      ignore => $_prerouting,
    }

    if $allow_docker {
      firewallchain { 'DOCKER:filter:IPv4':
        purge => false,
      }

      firewallchain { 'DOCKER:nat:IPv4':
        purge => false,
      }
    }

    if $allow_azure {
      # Azure creates firewall rules in the security table. Puppet can't manage
      # rules in this table, but we can avoid purging the rules that Azure creates.
      firewallchain { 'OUTPUT:security:IPv4':
        purge => false,
      }

      # For reference, these are the rules as copied from an Azure VM:
      #
      # firewall { '9001 52a22a6551f04aad4ff564ccd193573b7c4c4d942fce1b566e786b64935d9c40':
      #   ensure      => 'present',
      #   action      => 'accept',
      #   chain       => 'OUTPUT',
      #   destination => '168.63.129.16/32',
      #   dport       => ['53'],
      #   proto       => 'tcp',
      #   table       => 'security',
      # }
      #
      # firewall { '9002 6c34f301bce5c06717977b966cd9e282511074abfa1bf00e4bfb00099ca84fff':
      #   ensure      => 'present',
      #   action      => 'accept',
      #   chain       => 'OUTPUT',
      #   destination => '168.63.129.16/32',
      #   proto       => 'tcp',
      #   table       => 'security',
      # }
      #
      # firewall { '9003 5bfdc45a5b270a5c1659a5f13c81fe652160cdce4d68958f0233f6a159dc3202':
      #   ensure      => 'present',
      #   action      => 'drop',
      #   chain       => 'OUTPUT',
      #   ctstate     => ['INVALID', 'NEW'],
      #   destination => '168.63.129.16/32',
      #   proto       => 'tcp',
      #   table       => 'security',
      # }

    }

  } else {
    resources { 'firewall':
      purge => true,
    }
  }

  # Multicast DNS
  if $block_mdns {
    firewall { '010 drop mdns':
      chain       => 'INPUT',
      proto       => 'udp',
      destination => '224.0.0.251',
      jump        => $drop_action,
    }
  }

  # Kaspersky Security Center Cloud Console
  #
  # See https://support.kaspersky.com/KSC/CloudConsole/en-US/158830.htm
  if $block_kaspersky_sccc {
    firewall { '910 drop kaspersky sccc broadcast':
      chain       => 'INPUT',
      proto       => 'udp',
      dport       => 15000,
      destination => '255.255.255.255',
      jump        => $drop_action,
    }
  }

  # https://forums.centos.org/viewtopic.php?t=69517#p292129
  if $block_hasp_lm {
    firewall_multi { '910 drop hasp license manager broadcast':
      chain       => 'INPUT',
      proto       => 'udp',
      dport       => 1947,
      destination => '255.255.255.255',
      jump        => $drop_action,
    }
  }

  if $block_dhcp_broadcast {
    firewall { '950 ignore broadcast: dhcp':
      proto => 'udp',
      sport => 68,
      dport => 67,
      jump  => $drop_action,
    }
  }

  if $block_netbios_broadcast {
    firewall {
      default:
        proto => 'udp',
        jump  => $drop_action,
        ;
      '951 ignore netbios broadcast udp port 137':
        sport => 137,
        dport => 137,
        ;
      '952 ignore netbios broadcast udp port 138':
        sport => 138,
        dport => 138,
        ;
    }
  }

  # Block Bogons
  # https://en.wikipedia.org/wiki/Bogon_filtering
  if $block_bogons {
    class { 'ipset' : }

    ipset::set { 'bogons':
      ensure => ensure_present($block_bogons),
      type   => 'hash:net',
      set    => [
        '0.0.0.0/8',
        '10.0.0.0/8',
        '100.64.0.0/10',
        '169.254.0.0/16',
        '172.16.0.0/12',
        '192.0.0.0/24',
        '192.0.2.0/24',
        '192.88.99.0/24',
        '192.168.0.0/16',
        '198.18.0.0/15',
        '198.51.100.0/24',
        '203.0.113.0/24',
        '240.0.0.0/4',
      ],
    }

    ['src', 'dst'].each |$x| {
      firewall { "998 log drop bogon ${x} ips":
        chain       => 'OUTPUT',
        jump        => 'LOG',
        proto       => 'all',
        outiface    => $facts['networking']['primary'],
        source      => '! 127.0.0.1',
        destination => '! 127.0.0.1',
        log_prefix  => 'drop_bogons ',
        log_level   => 'debug',
        ipset       => "bogons ${x}",
      }

      firewall { "999 drop bogon ${x} ips":
        chain       => 'OUTPUT',
        jump        => $drop_action,
        outiface    => $facts['networking']['primary'],
        proto       => 'all',
        source      => '! 127.0.0.1',
        destination => '! 127.0.0.1',
        ipset       => "bogons ${x}",
      }
    }
  }

  # Add log prefix to any log rules so that we can easily find them in log files
  $_rules_log_prefix = $rules.filter |$_rule_name, $_rule_opts| {
    $_rule_opts['jump'] == 'LOG'
  }.map |$_rule_name, $_rule_opts| {
    # Remove the leading numeric prefix and turn it into a unique string. The
    # last character in the string should be a single space, as it'll otherwise
    # flow into the logged details.
    $_log_prefix = "${_rule_name.regsubst(/^([0-9]+ )?(.+)$/, '\2').safe_string(28)} "
    [
      $_rule_name,
      {
        'log_prefix' => $_log_prefix,
      } + $_rule_opts,
    ]
  }

  create_resources('firewall_multi', $rules + Hash($_rules_log_prefix))

}
