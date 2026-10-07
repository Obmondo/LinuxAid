# @summary manage in tor
# @param ports ports for tor
class nftables::rules::tor (
  Array[Stdlib::Port,1] $ports = [9001],
) {
  nftables::rule {
    'default_in-tor':
      content => "tcp dport {${join($ports,', ')}} accept",
  }
}
