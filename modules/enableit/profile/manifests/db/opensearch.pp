# Opensearch Profile
class profile::db::opensearch {

  # Monitoring
  # contain common::monitor::exporter::elasticsearch

  $nodes = [$facts.dig('network_primary_ip')]

  $access_9200_port_from = []

  # Merge the instances value
  $instances = {
    'cluster.name'                          => 'opensearch-cluster',
    'network.host'                          => [
      '_local_',
      $facts.dig('network_primary_ip'),
    ],
    'discovery.seed_hosts'                  => $nodes,
    'cluster.initial_cluster_manager_nodes' => $nodes,
    'path.data'                             => '/var/lib/opensearch',
    'plugins.security.ssl.http.enabled'     => false,

  }

  $_cluster_hosts = $instances.map |$_instance_name, $_instance_config| {
    $instances.dig('discovery.seed_hosts')
  }.flatten.delete_undef_values.sort

  # Get the Ipv4 Host from the array
  $_cluster_hosts_ipv4 = $_cluster_hosts.filter |$_host| {
    $_host =~ Stdlib::IP::Address::V4
  }

  # Get the Ipv6 Host from the array
  $_cluster_hosts_ipv6 = $_cluster_hosts.filter |$_host| {
    $_host =~ Stdlib::IP::Address::V6
  }

  # Setup Firewall
  Firewall_multi {
    ensure => present,
    proto  => 'tcp',
    action => 'accept',
  }

  if $_cluster_hosts_ipv4.count > 0 {
    firewall_multi { '000 allow opensearch ipv4':
      source => $_cluster_hosts_ipv4,
      dport  => 9300,
    }

    firewall_multi { '000 allow opensearch_api ipv4':
      source => $access_9200_port_from,
      dport  => 9200,
    }
  }

  if $_cluster_hosts_ipv6.count > 0 {
    firewall_multi { '000 allow opensearch ipv6':
      source   => $_cluster_hosts_ipv6,
      dport    => 9300,
      protocol => 'ip6tables',
    }

    firewall_multi { '000 allow opensearch_api ipv6':
      source   => $access_9200_port_from,
      dport    => 9200,
      protocol => 'ip6tables',
    }
  }

  $_naive_heap_gb = functions::memory_human_readable('GB')*(50/100.0)

  $_es_heap_size_g = clamp(1, $_naive_heap_gb, 31)

  # Setup Opensearch
  class { 'opensearch':
    version                   => '2.11.0',
    settings                  => $instances,
    pin_package               => true,
    heap_size                 => "${_es_heap_size_g}g",
    restart_on_package_change => false,
    restart_on_config_change  => false,
  }
}
