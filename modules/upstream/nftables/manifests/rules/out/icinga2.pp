# @summary allow outgoing icinga2
# @param ports icinga2 ports
class nftables::rules::out::icinga2 (
  Array[Stdlib::Port,1] $ports = [5665],
) {
  nftables::rule {
    'default_out-icinga2':
      content => "tcp dport {${join($ports,', ')}} accept",
  }
}
