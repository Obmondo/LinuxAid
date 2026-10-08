#
# @summary allow incoming IGMP messages
#
class nftables::rules::igmp {
  nftables::rule { 'default_in-igmp':
    content => 'ip daddr 224.0.0.22 accept',
  }
}
