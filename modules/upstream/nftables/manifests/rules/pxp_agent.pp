# @summary manage in pxp-agent
# @param ports pxp server ports
class nftables::rules::pxp_agent (
  Array[Stdlib::Port,1] $ports = [8142],
) {
  nftables::rule {
    'default_in-pxp_agent':
      content => "tcp dport {${join($ports,', ')}} accept",
  }
}
