# manage out nfs
class nftables::rules::out::nfs {
  nftables::rule {
    'default_out-nfs4':
      content => 'tcp dport nfs accept comment "Accept NFS4"',
  }
}
