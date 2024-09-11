# Opensearch Profile
class profile::db::opensearch (
  Eit_types::Version                  $version               = $role::db::opensearch::version,
  Eit_types::Percentage               $es_heap_size_pct      = $role::db::opensearch::es_heap_size_pct,
  Variant[Integer[1,31], Float[1,31]] $es_heap_size_max_gb   = $role::db::opensearch::es_heap_size_max_gb,
  Optional[Array[Stdlib::Host]]       $access_9200_port_from = $role::db::opensearch::access_9200_port_from,
  Array[Stdlib::Host]                 $nodes                 = $role::db::opensearch::nodes,
  Stdlib::Unixpath                    $datadir               = $role::db::opensearch::datadir,
  Eit_types::SimpleString             $cluster_name          = $role::db::opensearch::cluster_name,
  Hash[Eit_types::SimpleString, Hash] $curate_filters        = $role::db::opensearch::curate_filters,
){

  # Monitoring
  # contain common::monitor::exporter::elasticsearch

  # Merge the instances value
  $instances = {
    'cluster.name'                          => $cluster_name,
    'network.host'                          => [
      '_local_',
      $facts.dig('network_primary_ip'),
    ],
    'discovery.seed_hosts'                  => $nodes,
    'cluster.initial_cluster_manager_nodes' => $nodes,
    'path.data'                             => $datadir,
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

  $_memorysize_gb = $::facts['memorysize_mb']/1024

  $_naive_heap_gb = $_memorysize_gb*($es_heap_size_pct/100.0)

  $_es_heap_size_g = clamp(1, $_naive_heap_gb, $es_heap_size_max_gb)

  # Setup Opensearch
  class { 'opensearch':
    version                   => $version,
    settings                  => $instances,
    pin_package               => true,
    heap_size                 => "${_es_heap_size_g}g",
    restart_on_package_change => false,
    restart_on_config_change  => false,
  }
}
