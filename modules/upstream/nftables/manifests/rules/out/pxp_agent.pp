# @summary manage outgoing pxp-agent
#
# @param broker PXP broker IP(s)
# @param broker_port PXP broker port
#
# @see also take a look at nftables::rules::out::puppet, because the PXP agent also connects to a Puppetserver
#
class nftables::rules::out::pxp_agent (
  Variant[Stdlib::IP::Address,Array[Stdlib::IP::Address,1]] $broker,
  Stdlib::Port $broker_port = 8142,
) {
  Array($broker, true).each |$index,$ps| {
    nftables::rule {
      "default_out-pxpagent-${index}":
    }
    if $ps =~ Stdlib::IP::Address::V6 {
      Nftables::Rule["default_out-pxpagent-${index}"] {
        content => "ip6 daddr ${ps} tcp dport ${broker_port} accept",
      }
    } else {
      Nftables::Rule["default_out-pxpagent-${index}"] {
        content => "ip daddr ${ps} tcp dport ${broker_port} accept",
      }
    }
  }
}
