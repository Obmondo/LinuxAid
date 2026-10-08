#
# @summary allow incoming multicast traffic
#
class nftables::rules::multicast {
  nftables::rule {
    'default_in-multicast':
      content => 'ip daddr 224.0.0.1 accept',
  }
}
