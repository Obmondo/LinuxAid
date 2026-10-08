# @summary Provides a simplified interface to nftables::rule
#
# @example allow incoming traffic from port 541 on port 543 TCP to a given IP range and count packets
#   nftables::simplerule{'my_service_in':
#     action  => 'accept',
#     comment => 'allow traffic to port 543',
#     counter => true,
#     proto   => 'tcp',
#     dport   => 543,
#     daddr   => '2001:1458::/32',
#     sport   => 541,
#   }
# @param ensure
#   Should the rule be created.
#
# @param rulename
#   The symbolic name for the rule to add. Defaults to the resource's title.
#
# @param order
#   A number representing the order of the rule.
#
# @param chain
#   The name of the chain to add this rule to.
#
# @param table
#   The name of the table to add this rule to.
#
# @param action
#   The verdict for the matched traffic.
#
# @param comment
#   A typically human-readable comment for the rule.
#
# @param dport
#   The destination port, ports or port range.
#
# @param proto
#   The transport-layer protocol to match.
#
# @param daddr
#   The destination address, CIDR or set to match.
#
# @param set_type
#   When using sets as saddr or daddr, the type of the set.
#   Use `ip` for sets of type `ipv4_addr`.
#
# @param sport
#   The source port, ports or port range.
#
# @param saddr
#   The source address, CIDR or set to match.
#
# @param counter
#   Enable traffic counters for the matched traffic.
#
# @param iifname
#   Optional filter for the incoming interface
# @param oifname
#   Optional filter for the outgoing interface
define nftables::simplerule (
  Enum['present','absent'] $ensure = 'present',
  Nftables::SimpleRuleName $rulename = $title,
  Pattern[/^\d\d$/] $order = '50',
  String $chain  = 'default_in',
  String $table = 'inet-filter',
  Enum['accept', 'continue', 'drop', 'queue', 'return'] $action = 'accept',
  Optional[String] $comment = undef,
  Optional[Nftables::Port] $dport = undef,
  Optional[Enum['tcp', 'tcp4', 'tcp6', 'udp', 'udp4', 'udp6']] $proto = undef,
  Optional[Nftables::Addr] $daddr = undef,
  Enum['ip', 'ip6'] $set_type = 'ip6',
  Optional[Nftables::Port] $sport = undef,
  Optional[Nftables::Addr] $saddr = undef,
  Boolean $counter = false,
  Variant[Array[String[1]],String[1]] $iifname = [],
  Variant[Array[String[1]],String[1]] $oifname = [],
) {
  if $dport and !$proto {
    fail('Specifying a transport protocol via $proto is mandatory when passing a $dport')
  }

  if $sport and !$proto {
    fail('Specifying a transport protocol via $proto is mandatory when passing a $sport')
  }

  if $ensure == 'present' {
    nftables::rule { "${chain}-${rulename}":
      content => epp('nftables/simplerule.epp',
        {
          'action'   => $action,
          'comment'  => $comment,
          'counter'  => $counter,
          'daddr'    => $daddr,
          'dport'    => $dport,
          'proto'    => $proto,
          'saddr'    => $saddr,
          'set_type' => $set_type,
          'sport'    => $sport,
          'iifname'  => [$iifname].flatten,
          'oifname'  => [$oifname].flatten,
        }
      ),
      order   => $order,
      table   => $table,
    }
  }
}
