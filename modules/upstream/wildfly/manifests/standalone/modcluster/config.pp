#
# Configures modcluster subsystem
#
define wildfly::standalone::modcluster::config($advertise_socket = 'modcluster', $connector = 'ajp', $type = 'busyness', $balancer = undef, $load_balancing_group = undef, $proxy_list = undef, $proxy_url = undef) {

  $config = {
    'advertise-socket' => $advertise_socket,
    'connector' => $connector,
    'balancer' => $balancer,
    'load-balancing-group' => $load_balancing_group,
    'proxy-url' => $proxy_url,
    'proxy-list' => $proxy_list
  }

  wildfly::util::resource { '/subsystem=modcluster/mod-cluster-config=configuration':
    content => $config
  }
  ->
  wildfly::util::resource { '/subsystem=modcluster/mod-cluster-config=configuration/dynamic-load-provider=configuration':
    content => {}
  }
  ->
  wildfly::util::resource { "/subsystem=modcluster/mod-cluster-config=configuration/dynamic-load-provider=configuration/load-metric=${type}":
    content => { 'type' => $type }
  }

}