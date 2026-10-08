# @summary
#   Ceph is a distributed object store and file system.
#   Enable this option to support Ceph's Monitor Daemon.
# @param ports specify ports for ceph service
class nftables::rules::ceph_mon (
  Array[Stdlib::Port,1] $ports = [3300, 6789],
) {
  nftables::rule {
    'default_in-ceph_mon':
      content => "tcp dport {${$ports.join(', ')}} accept comment \"Accept Ceph MON\"",
  }
}
