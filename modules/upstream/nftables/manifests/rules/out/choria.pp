#
# @summary manage outgoing connections to choria brokers
#
# @param brokers list of brokers where you want to connect to
# @param choria_port where the broker listens for incoming server connections
# @param websocket_port where the broker listens for incoming websocket connections from servers
# @param enable_websockets websockets are optional and use a different port
#
# @see https://choria.io/docs/deployment/broker/
#
# @author Tim Meusel <tim@bastelfreak.de>
#
class nftables::rules::out::choria (
  Array[Stdlib::IP::Address] $brokers = [],
  Stdlib::Port $choria_port = 4222,
  Stdlib::Port $websocket_port = 4333,
  Boolean $enable_websockets = true,
) {
  if empty($brokers) {
    nftables::rule { 'default_out-choria-0':
      content => "tcp dport ${choria_port} accept",
    }
    if $enable_websockets {
      nftables::rule { 'default_out-choriawebsocket-0':
        content => "tcp dport ${choria_port} accept",
      }
    }
  }
  else {
    $brokers.each |$index,$ip| {
      if $ip =~ Stdlib::IP::Address::V6 {
        nftables::rule { "default_out-choria-${index}":
          content => "ip6 daddr ${ip} tcp dport ${choria_port} accept",
        }
      } else {
        nftables::rule { "default_out-choria-${index}":
          content => "ip daddr ${ip} tcp dport ${choria_port} accept",
        }
      }
      if $enable_websockets {
        if $ip =~ Stdlib::IP::Address::V6 {
          nftables::rule { "default_out-choriawebsocket-${index}":
            content => "ip6 daddr ${ip} tcp dport ${websocket_port} accept",
          }
        } else {
          nftables::rule { "default_out-choriawebsocket-${index}":
            content => "ip daddr ${ip} tcp dport ${websocket_port} accept",
          }
        }
      }
    }
  }
}
