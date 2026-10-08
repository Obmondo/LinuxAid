# Ceph is a distributed object store and file system.
# Enable this to support Ceph's Object Storage Daemons (OSD),
# Metadata Server Daemons (MDS), or Manager Daemons (MGR).
class nftables::rules::ceph {
  nftables::rule {
    'default_in-ceph':
      content => 'tcp dport 6800-7300 accept comment "Accept Ceph OSD, MDS, MGR"',
  }
}
