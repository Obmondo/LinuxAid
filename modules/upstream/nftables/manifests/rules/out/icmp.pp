# @summary control outbound icmp packages
#
# @param v4_types ICMP v4 types that should be allowed
# @param v6_types ICMP v6 types that should be allowed
# @param order the ordering of the rules
#
class nftables::rules::out::icmp (
  Optional[Array[String]] $v4_types = undef,
  Optional[Array[String]] $v6_types = undef,
  String $order = '10',
) {
  if $v4_types {
    $v4_types.each | String $icmp_type | {
      # make sure we get a unique rulename per icmp_type
      nftables::rule { "default_out-accept_icmpv4_${regsubst(split($icmp_type, ' ')[0], '-', '_', 'G')}":
        content => "ip protocol icmp icmp type ${icmp_type} accept",
        order   => $order,
      }
    }
  } elsif $v6_types {
    nftables::rule { 'default_out-accept_icmpv4':
      content => 'ip protocol icmp accept',
      order   => $order,
    }
  }

  if $v6_types {
    $v6_types.each | String $icmp_type | {
      # make sure we get a unique rulename per icmp_type
      nftables::rule { "default_out-accept_icmpv6_${regsubst(split($icmp_type, ' ')[0], '-', '_', 'G')}":
        content => "ip6 nexthdr ipv6-icmp icmpv6 type ${icmp_type} accept",
        order   => $order,
      }
    }
  } elsif $v4_types {
    # `ip6 nexthdr ipv6-icmp accept` doesn't match for IPv6 ICMP with extensions
    # context: https://www.rfc-editor.org/rfc/rfc3810#section-5
    # https://wiki.nftables.org/wiki-nftables/index.php/Matching_packet_headers#Matching_IPv6_headers
    nftables::rule { 'default_out-accept_icmpv6':
      content => 'meta l4proto icmpv6 accept',
      order   => $order,
    }
  }

  if $v6_types == undef and $v4_types == undef {
    nftables::rule { 'default_out-accept_icmp':
      content => 'meta l4proto { icmp, icmpv6} accept',
      order   => $order,
    }
  }
}
