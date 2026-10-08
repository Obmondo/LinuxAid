#
# @summary allow incoming spotify
#
class nftables::rules::spotify {
  nftables::rule { 'default_in-spotify':
    content => 'udp sport 57621 udp dport 57621 accept',
  }
}
