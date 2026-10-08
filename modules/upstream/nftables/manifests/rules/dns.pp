# @summary manage in dns
# @param ports Specify ports for dns.
# @param iifname Specify input interface names.
#
# @example Allow access to stub dns resolver from docker containers
#   class { 'nftables::rules::dns':
#     iifname => ['docker0'],
#   }
#
class nftables::rules::dns (
  Array[Stdlib::Port,1] $ports = [53],
  Optional[Array[String[1],1]] $iifname = undef,
) {
  $_iifname = $iifname ? {
    Undef   => '',
    default => "iifname {${join($iifname, ', ')}} ",
  }

  nftables::rule {
    'default_in-dns_tcp':
      content => "${_iifname}tcp dport {${join($ports,', ')}} accept";
    'default_in-dns_udp':
      content => "${_iifname}udp dport {${join($ports,', ')}} accept";
  }
}
