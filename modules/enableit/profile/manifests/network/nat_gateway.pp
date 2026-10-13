# @summary Class for turning a host into a NAT gateway
#
# Turns on IPv4 forwarding, adds the masquerade rule and makes sure the rule is
# saved, so the host keeps forwarding after a reboot.
# See common::network::nat_gateway for the hiera-facing parameters.
#
# @param enable Whether the host acts as a NAT gateway.
#
# @param noop_value Noop value for the resources of this class.
#
# @param source Networks to masquerade, in CIDR notation.
#
# @param out_interface Interface the masqueraded traffic leaves through.
#
class profile::network::nat_gateway (
  Boolean                              $enable        = $common::network::nat_gateway::enable,
  Eit_types::Noop_Value                $noop_value    = $common::network::nat_gateway::noop_value,
  Array[Stdlib::IP::Address::V4::CIDR] $source        = $common::network::nat_gateway::source,
  Optional[String[1]]                  $out_interface = $common::network::nat_gateway::out_interface,
) {
  if $enable {
    $_out_interface = pick($out_interface, $facts['networking']['primary'])

    # NOTE: both defined() calls below rely on this class being evaluated after
    # common::network and common::system, see the end of the common class.
    $_firewall_managed = defined(Class['profile::network::firewall'])

    # Something has to save the rule and load it again at boot. The managed
    # firewall does that on every OS family. Without it only the Debian family
    # is safe: netfilter-persistent restores what was saved and nothing else,
    # while the iptables service elsewhere ships a rule set that rejects forwarding.
    confine(!$_firewall_managed, $facts['os']['family'] != 'Debian',
      'common::network::nat_gateway needs the managed firewall (common::network::firewall::enable and ::manage) on this OS family')

    # Not the firewall class here: a noop set on a class does not reach the
    # resources inside it, and this has to apply on hosts that run in noop mode.
    unless $_firewall_managed {
      package { 'iptables-persistent':
        ensure => installed,
        noop   => $noop_value,
      }

      service { 'netfilter-persistent':
        ensure  => running,
        enable  => true,
        noop    => $noop_value,
        require => Package['iptables-persistent'],
      }
    }

    $_persistence = if $_firewall_managed { Class['firewall'] } else { Service['netfilter-persistent'] }

    # A host may already set this through common::system::kernel::sysctl
    unless defined(Sysctl::Configuration['net.ipv4.ip_forward']) {
      sysctl::configuration { 'net.ipv4.ip_forward':
        value => '1',
        noop  => $noop_value,
      }
    }

    $_sources = if $source.empty { [undef] } else { $source }

    $_sources.each |$_cidr| {
      $_title = if $_cidr { "100 nat gateway masquerade ${_cidr}" } else { '100 nat gateway masquerade' }

      # proto defaults to tcp, which would leave udp and icmp out
      firewall { $_title:
        table    => 'nat',
        chain    => 'POSTROUTING',
        proto    => 'all',
        source   => $_cidr,
        outiface => $_out_interface,
        jump     => 'MASQUERADE',
        protocol => 'iptables',
        noop     => $noop_value,
        require  => $_persistence,
      }
    }
  }
}
