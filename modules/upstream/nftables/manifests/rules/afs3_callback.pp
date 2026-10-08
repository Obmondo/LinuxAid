# @summary Open call back port for AFS clients
# @param saddr list of source network ranges to a
# @example allow call backs from particular hosts
#  class{'nftables::rules::afs3_callback':
#    saddr => ['192.168.0.0/16', '10.0.0.222']
#  }
#
class nftables::rules::afs3_callback (
  Array[Stdlib::IP::Address::V4,1] $saddr = ['0.0.0.0/0'],
) {
  nftables::rule { 'default_in-afs3_callback':
    content => "ip saddr { ${saddr.join(', ')} } udp dport 7001 accept";
  }
}
