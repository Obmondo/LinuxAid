# @summary manage port openings for a nomad cluster
#
# @param cluster_elements IP addreses of nomad cluster nodes
# @param http Specify http api port to open to the world.
# @param rpc Specify rpc port to open within the nomad cluster
# @param serf Specify serf port to open within the nomad cluster
#
# @example Simple two node nomad cluster
#  class{ 'nftables::rules::nomad':
#    cluster_elements = [
#      '10.0.0.1','10.0.0.2',
#      '::1', '::2'',
#    ],
#  }
#
class nftables::rules::nomad (
  Stdlib::Port $http = 4646,
  Stdlib::Port $rpc  = 4647,
  Stdlib::Port $serf = 4648,
  Array[Stdlib::IP::Address,1] $cluster_elements = ['127.0.0.1','::1'],
) {
  # Open http api port to everything.
  #
  nftables::rule { 'default_in-nomad_http':
    content => "tcp dport ${http} accept",
  }

  ['ip','ip6'].each | $_family | {
    $_ip_type = $_family ? {
      'ip'    => Stdlib::IP::Address::V4,
      default => Stdlib::IP::Address::V6,
    }
    $_set_type = $_family ? {
      'ip'    => 'ipv4_addr',
      default => 'ipv6_addr',
    }

    $_elements = $cluster_elements.filter | $_ip | { $_ip =~ $_ip_type }

    if $_elements.length > 0 {
      nftables::set { "nomad_${_family}":
        elements => $_elements,
        type     => $_set_type,
      }

      nftables::rule { "default_in-nomad_rpc_${_family}":
        content => "tcp dport ${rpc} ${_family} saddr @nomad_${_family} accept",
      }

      nftables::rule { "default_in-nomad_serf_udp_${_family}":
        content => "udp dport ${serf} ${_family} saddr @nomad_${_family} accept",
      }

      nftables::rule { "default_in-nomad_serf_tcp_${_family}":
        content => "tcp dport ${serf} ${_family} saddr @nomad_${_family} accept",
      }
    }
  }
}
