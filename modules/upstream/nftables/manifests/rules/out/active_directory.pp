# @summary manage outgoing active diectory
# @param adserver adserver IPs
# @param adserver_ports adserver ports
#
class nftables::rules::out::active_directory (
  Variant[Stdlib::IP::Address,Array[Stdlib::IP::Address,1]] $adserver,
  Array[Stdlib::Port,1] $adserver_ports = [389, 636, 3268, 3269],
) {
  Array($adserver, true).each |$index,$as| {
    nftables::rule {
      "default_out-adserver-${index}":
    }
    if $as =~ Stdlib::IP::Address::V6 {
      Nftables::Rule["default_out-adserver-${index}"] {
        content => "ip6 daddr ${as} tcp dport {${join($adserver_ports,', ')}} accept",
      }
    } else {
      Nftables::Rule["default_out-adserver-${index}"] {
        content => "ip daddr ${as} tcp dport {${join($adserver_ports,', ')}} accept",
      }
    }
  }
}
