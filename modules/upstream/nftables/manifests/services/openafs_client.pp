# @summary Open inbound and outbound ports for an AFS client
class nftables::services::openafs_client inherits nftables {
  if $nftables::out_all {
    fail('All outgoing traffic is allowed, you might want to use only nftables::rules::afs3_callback')
  }

  include nftables::rules::afs3_callback
  include nftables::rules::out::openafs_client
}
