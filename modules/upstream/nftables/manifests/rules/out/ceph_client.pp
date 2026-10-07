# @summary
#   Ceph is a distributed object store and file system.
#   Enable this to be a client of Ceph's Monitor (MON),
#   Object Storage Daemons (OSD), Metadata Server Daemons (MDS),
#   and Manager Daemons (MGR).
# @param ports Specify ports to open
class nftables::rules::out::ceph_client (
  Array[Stdlib::Port,1] $ports = [3300, 6789],
) {
  nftables::rule {
    'default_out-ceph_client':
      content => "tcp dport { ${$ports.join(', ')}, 6800-7300 } accept comment \"Accept Ceph MON, OSD, MDS, MGR\"",
  }
}
