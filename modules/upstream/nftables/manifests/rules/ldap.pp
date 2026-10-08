# @summary manage in ldap
# @param ports ldap server ports
class nftables::rules::ldap (
  Array[Integer,1] $ports = [389, 636],
) {
  nftables::rule {
    'default_in-ldap':
      content => "tcp dport {${join($ports,', ')}} accept",
  }
}
