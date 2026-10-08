# @summary manage in mosh
# @param ports mosh port range
class nftables::rules::mosh (
  Nftables::Port::Range $ports = '60000-61000',
) {
  nftables::rule {
    'default_in-mosh':
      content => "udp dport ${ports} accept",
  }
}
