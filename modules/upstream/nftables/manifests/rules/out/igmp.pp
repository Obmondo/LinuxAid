#
# @summary allow outgoing IGMP messages
#
class nftables::rules::out::igmp {
  nftables::rule { 'default_out-igmp':
    content => 'ip daddr 224.0.0.22 accept',
  }
}
