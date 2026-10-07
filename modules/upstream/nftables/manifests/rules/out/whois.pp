# @summary allow clients to query remote whois server
class nftables::rules::out::whois {
  nftables::rule { 'default_out-whois':
    content => 'tcp dport {43, 4321} accept comment "default_out-whois"',
  }
}
