# @summary manage Samba, the suite to allow Windows file sharing on Linux resources.
#
# @param ctdb Enable ctdb-driven clustered Samba setups
# @param action if the traffic should be allowed or dropped
#
class nftables::rules::samba (
  Boolean $ctdb = false,
  Enum['accept', 'drop'] $action = 'accept',
) {
  nftables::rule {
    'default_in-netbios_tcp':
      content => "tcp dport {139,445} ${action}",
  }

  nftables::rule {
    'default_in-netbios_udp':
      content => "udp dport {137,138} ${action}",
  }

  if $ctdb {
    nftables::rule {
      'default_in-ctdb':
        content => "tcp dport 4379 ${action}",
    }
  }
}
