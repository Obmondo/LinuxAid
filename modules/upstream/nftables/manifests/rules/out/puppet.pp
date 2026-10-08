# @summary manage outgoing puppet
# @param puppetserver puppetserver hostname
# @param puppetserver_port puppetserver port
#
class nftables::rules::out::puppet (
  Variant[Stdlib::IP::Address,Array[Stdlib::IP::Address,1]] $puppetserver,
  Stdlib::Port $puppetserver_port = 8140,
) {
  Array($puppetserver, true).each |$index,$ps| {
    nftables::rule {
      "default_out-puppet-${index}":
    }
    if $ps =~ Stdlib::IP::Address::V6 {
      Nftables::Rule["default_out-puppet-${index}"] {
        content => "ip6 daddr ${ps} tcp dport ${puppetserver_port} accept",
      }
    } else {
      Nftables::Rule["default_out-puppet-${index}"] {
        content => "ip daddr ${ps} tcp dport ${puppetserver_port} accept",
      }
    }
  }
}
