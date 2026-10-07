# manage in nfs3
class nftables::rules::nfs3 {
  nftables::rule {
    'default_in-nfs3':
      content => 'meta l4proto { tcp, udp } th dport nfs accept comment "Accept NFS3"',
  }
}
