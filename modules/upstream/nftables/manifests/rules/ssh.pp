# @summary manage in ssh
# @param ports ssh ports
class nftables::rules::ssh (
  Array[Stdlib::Port,1] $ports = [22],
) {
  nftables::rule {
    'default_in-ssh':
      content => "tcp dport {${join($ports,', ')}} accept",
  }
}
