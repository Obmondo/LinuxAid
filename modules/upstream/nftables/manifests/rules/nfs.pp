# manage in nfs4
class nftables::rules::nfs {
  nftables::rule {
    'default_in-nfs4':
      content => 'tcp dport nfs accept comment "Accept NFS4"',
  }
}
