# @summary manage outgoing ldap
# @param ldapserver ldapserver IPs
# @param ldapserver_ports ldapserver ports
#
class nftables::rules::out::ldap (
  Variant[Stdlib::IP::Address,Array[Stdlib::IP::Address,1]] $ldapserver,
  Array[Stdlib::Port,1] $ldapserver_ports = [389, 636],
) {
  Array($ldapserver, true).each |$index,$ls| {
    nftables::rule {
      "default_out-ldapserver-${index}":
    }
    if $ls =~ Stdlib::IP::Address::V6 {
      Nftables::Rule["default_out-ldapserver-${index}"] {
        content => "ip6 daddr ${ls} tcp dport {${join($ldapserver_ports,', ')}} accept",
      }
    } else {
      Nftables::Rule["default_out-ldapserver-${index}"] {
        content => "ip daddr ${ls} tcp dport {${join($ldapserver_ports,', ')}} accept",
      }
    }
  }
}
