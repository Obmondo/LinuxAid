# @summary
#  allows outbound access for afs clients
#  7000 - afs3-fileserver
#  7002 - afs3-ptserver
#  7003 - vlserver
# @param ports port numbers to use
# @see https://wiki.openafs.org/devel/AFSServicePorts/ AFS Service Ports
#
class nftables::rules::out::openafs_client (
  Array[Stdlib::Port,1] $ports = [7000, 7002, 7003],
) {
  include nftables::rules::out::kerberos

  nftables::rule { 'default_out-openafs_client':
    content => "udp dport {${$ports.join(', ')}} accept";
  }
}
