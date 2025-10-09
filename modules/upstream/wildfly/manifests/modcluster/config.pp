#
# Configures modcluster subsystem
#
define wildfly::modcluster::config(
  $advertise_socket = 'modcluster',
  $connector = 'ajp',
  $type = 'busyness',
  $excluded_contexts = undef,
  $balancer = undef,
  $load_balancing_group = undef,
  $proxy_list = undef,
  $proxies = undef,
  $proxy_url = undef,
  $sticky_session = undef,
  $target_profile = undef) {

  $config = {
    'advertise-socket' => $advertise_socket,
    'balancer' => $balancer,
    'connector' => $connector,
    'excluded-contexts' => $excluded_contexts,
    'load-balancing-group' => $load_balancing_group,
    'proxy-url' => $proxy_url,
    'proxy-list' => $proxy_list,
    'proxies' => $proxies,
    'sticky-session' => $sticky_session,
  }

  wildfly::resource { '/subsystem=modcluster/mod-cluster-config=configuration':
    content => $config,
    profile => $target_profile,
  }
  ->
  wildfly::resource { '/subsystem=modcluster/mod-cluster-config=configuration/dynamic-load-provider=configuration':
    content => {},
    profile => $target_profile,
  }
  ->
  wildfly::resource { "/subsystem=modcluster/mod-cluster-config=configuration/dynamic-load-provider=configuration/load-metric=${type}":
    content => {
      'type' => $type
    },
    profile => $target_profile,
  }

}
