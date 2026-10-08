# @summary 
#  Rules for Podman, a tool for managing OCI containers and pods.
#  This class defines additional forwarding rules to let root containers
#  reach external networks when using Netavark (since v4.0) or CNI (deprecated).
#  At the time of writing, Podman supports automatic configuration
#  of firewall rules with iptables and firewalld only.
#
class nftables::rules::podman {
  nftables::rule {
    'default_fwd-podman_establised':
      content => 'ip daddr 10.88.0.0/16 ct state related,established accept',
  }
  nftables::rule {
    'default_fwd-podman_accept':
      content => 'ip saddr 10.88.0.0/16 accept',
  }
}
