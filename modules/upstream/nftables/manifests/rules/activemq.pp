# @summary Provides input rules for Apache ActiveMQ
#
# @param tcp
#   Create the rule for TCP traffic.
#
# @param udp
#   Create the rule for UDP traffic.
#
# @param port
#   The port number for the ActiveMQ daemon.
class nftables::rules::activemq (
  Boolean $tcp = true,
  Boolean $udp = true,
  Stdlib::Port $port = 61616,
) {
  if $tcp {
    nftables::rule {
      'default_in-activemq_tcp':
        content => "tcp dport ${port} accept",
    }
  }

  if $udp {
    nftables::rule {
      'default_in-activemq_udp':
        content => "udp dport ${port} accept",
    }
  }
}
