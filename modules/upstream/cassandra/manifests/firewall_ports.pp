# An optional class to configure incoming network ports on the host that are
# relevant to the Cassandra installation.  If firewalls are being managed
# already, simply do not include this module in your manifest.
#
# IMPORTANT: The full list of which ports should be configured is assessed at
# evaluation time of the configuration. Therefore if one is to use this class,
# it must be the final cassandra class included in the manifest.
# @param client_ports [array] Only has any effect if the `cassandra` class is defined on the node.
#   Allow these TCP ports to be opened for traffic coming from the client
#   subnets.
# @param client_subnets [array] Only has any effect if the `cassandra` class is defined on the node.
#   An array of the list of subnets that are to allowed connection to
#   cassandra::native_transport_port and cassandra::rpc_port.
# @param inter_node_ports [array] Only has any effect if the `cassandra` class is defined on the node.
#   Allow these TCP ports to be opened for traffic between the Cassandra nodes.
# @param inter_node_subnets [array] Only has any effect if the `cassandra` class is defined on the node.
#   An array of the list of subnets that are to allowed connection to
#   `cassandra::storage_port`, `cassandra::ssl_storage_port` and port 7199
#   for cassandra JMX monitoring.
# @param public_ports [array] Allow these TCP ports to be opened for traffic
#   coming from public subnets the port specified in `$ssh_port` will be
#   appended to this list.
# @param public_subnets [array] An array of the list of subnets that are to allowed connection to
#   cassandra::firewall_ports::ssh_port.
# @param ssh_port [integer] Which port does SSH operate on.
# @param opscenter_ports [array] Only has any effect if the `cassandra::datastax_agent` is defined.
#   Allow these TCP ports to be opened for traffic coming to or from OpsCenter
#   appended to this list.
# @param opscenter_subnets [array] A list of subnets that are to be allowed connection to
#   port 61621 for nodes built with cassandra::datastax_agent.
class cassandra::firewall_ports (
  $client_ports                = [9042, 9160],
  $client_subnets              = ['0.0.0.0/0'],
  $inter_node_ports            = [7000, 7001, 7199],
  $inter_node_subnets          = ['0.0.0.0/0'],
  $public_ports                = [8888],
  $public_subnets              = ['0.0.0.0/0'],
  $ssh_port                    = 22,
  $opscenter_ports             = [9042, 9160, 61620, 61621],
  $opscenter_subnets           = ['0.0.0.0/0'],
) {
  # Public connections on any node.
  $public_subnets_array = prefix($public_subnets, '200_Public_')

  cassandra::private::firewall_ports::rule { $public_subnets_array:
    ports => concat($public_ports, [$ssh_port]),
  }

  # If this is a Cassandra node.
  if defined ( Class['::cassandra']) {
    # Inter-node connections for Cassandra
    $inter_node_subnets_array = prefix($inter_node_subnets, '210_InterNode_')

    cassandra::private::firewall_ports::rule { $inter_node_subnets_array:
      ports => $inter_node_ports,
    }

    # Client connections for Cassandra
    $client_subnets_array = prefix($client_subnets, '220_Client_')

    cassandra::private::firewall_ports::rule { $client_subnets_array:
      ports => $client_ports,
    }
  }

  # Connections for DataStax Agent
  if defined ( Class['::cassandra::datastax_agent']) or defined ( Class['::cassandra::opscenter']) {
    $opscenter_subnets_opc_agent = prefix($opscenter_subnets, '230_OpsCenter_')

    cassandra::private::firewall_ports::rule { $opscenter_subnets_opc_agent:
      ports => $opscenter_ports,
    }
  }
}
