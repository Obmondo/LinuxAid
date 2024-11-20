# Elasticsearch profile
#
# Puppet module does not support 8.x and Zscaler needs 8.x only
#
# Cert Setup
# NOTE: The cert are automatically setup when it's a fresh installation
# if the cert are not generated, you will have to purge/remove the elasticsearch
# rm the /etc/elasticsearch and /var/lib/elasticsearch
# and install the elasticsearch again
#
# kibana_system password
# /usr/share/elasticsearch/bin/elasticsearch-reset-password --username kibana_system
#
# The password is shown when you install it manually (atleast on Ubuntu)
# The generated password for the elastic built-in superuser is : dKTmDZon7*2HLCbIcNPa
# if for some reason, you can't you can reset the password with the above command
# /usr/share/elasticsearch/bin/elasticsearch-reset-password --username elastic
#
# Cert created by elasticsearch is better, otherwise some cli commands fails
# so use self-signed cert by cautious
#
# add base64 encoded string for the cert
# base64 -i /path/to/cert.p12
# TODO: write a puppet provider to support this.
class profile::db::elasticsearch (
  Eit_types::Version                  $version               = $role::db::elasticsearch::version,
  Boolean                             $security              = $role::db::elasticsearch::security,
  Boolean                             $oss                   = $role::db::elasticsearch::oss,
  Boolean                             $ssl                   = $role::db::elasticsearch::ssl,
  Optional[Hash]                      $plugins               = $role::db::elasticsearch::plugins,
  Optional[Hash]                      $secrets               = $role::db::elasticsearch::secrets,
  Eit_types::Percentage               $es_heap_size_pct      = $role::db::elasticsearch::es_heap_size_pct,
  Variant[Integer[1,31], Float[1,31]] $es_heap_size_max_gb   = $role::db::elasticsearch::es_heap_size_max_gb,
  Optional[Array[Stdlib::Host]]       $access_9200_port_from = $role::db::elasticsearch::access_9200_port_from,
  Array[Stdlib::Host]                 $nodes                 = $role::db::elasticsearch::nodes,
  Stdlib::Unixpath                    $datadir               = $role::db::elasticsearch::datadir,
  Optional[String]                    $ca_cert               = $role::db::elasticsearch::ca_cert,
  Eit_types::SimpleString             $cluster_name          = $role::db::elasticsearch::cluster_name,
  Hash[Eit_types::SimpleString, Hash] $curate_filters        = $role::db::elasticsearch::curate_filters,
  Optional[String]                    $transport             = $role::db::elasticsearch::transport,
  Optional[String]                    $http                  = $role::db::elasticsearch::http,
) {

  # Monitoring
  # contain common::monitor::exporter::elasticsearch

  $etc_elasticsearch = '/etc/elasticsearch'

  file { "${etc_elasticsearch}/certs" :
    ensure => directory,
    owner  => 'elasticsearch',
    group  => 'elasticsearch',
  }

  file { "${etc_elasticsearch}/certs/http.p12":
    ensure  => 'file',
    content => base64('decode', $http),
    mode    => '0600',
    owner   => 'elasticsearch',
    group   => 'elasticsearch',
  }

  file { "${etc_elasticsearch}/certs/transport.p12":
    ensure  => 'file',
    content => base64('decode', $transport),
    mode    => '0600',
    owner   => 'elasticsearch',
    group   => 'elasticsearch',
  }

  file { "${etc_elasticsearch}/certs/http_ca.crt":
    ensure  => 'file',
    content => $ca_cert,
    owner   => 'elasticsearch',
    group   => 'elasticsearch',
    mode    => '0400',
  }

  apt::pin { pin_elasticsearch:
    packages => 'elasticsearch',
    version  => $version,
    priority => '1001',
  }

  # Merge the instances value
  $instances = {
    'cluster.name' => $cluster_name,
    'network.host' => [
      '_local_',
      $facts.dig('network_primary_ip'),
    ],
    'discovery.seed_hosts'         => $nodes,
    'cluster.initial_master_nodes' => $nodes,
    'xpack.security' => {
      'enabled' => if !$oss { $security },
    },
    'xpack.security.enrollment' => {
      'enabled' => if !$oss { $security },
    },
    'xpack.security.http.ssl' => {
      'enabled'       => if !$oss { $security },
      'keystore.path' => 'certs/http.p12',
    },
    'xpack.security.transport.ssl' => {
      'enabled'           => if !$oss { $security },
      'keystore.path'     => 'certs/transport.p12',
      'truststore.path'   => 'certs/transport.p12',
      'verification_mode' => 'certificate',
    }
  }

  sysctl::configuration { 'vm.max_map_count':
    value => String(262144),
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
    jump   => 'accept',
  }

  if $_cluster_hosts_ipv4.count > 0 {
    firewall_multi { '000 allow elasticsearch ipv4':
      source => $_cluster_hosts_ipv4,
      dport  => 9300,
    }

    firewall_multi { '000 allow elasticsearch_api ipv4':
      source => $access_9200_port_from,
      dport  => 9200,
    }
  }

  if $_cluster_hosts_ipv6.count > 0 {
    firewall_multi { '000 allow elasticsearch ipv6':
      source   => $_cluster_hosts_ipv6,
      dport    => 9300,
      protocol => 'ip6tables',
    }

    firewall_multi { '000 allow elasticsearch_api ipv6':
      source   => $access_9200_port_from,
      dport    => 9200,
      protocol => 'ip6tables',
    }
  }

  $_memorysize_gb = $::facts.dig('memory', 'system', 'total_bytes')/(1024 * 1024 * 1024)

  $_naive_heap_gb = $_memorysize_gb*($es_heap_size_pct/100.0)

  $_es_heap_size_g = clamp(1, $_naive_heap_gb, $es_heap_size_max_gb)

  # Setup Java
  class { '::profile::java' :
    distribution => 'jre',
  }

  # Setup Repo
  class { 'elastic_stack::repo':
    oss     => $oss,
    version => Integer(split($version, '\.')[0])
  }

  # Setup elasticsearch
  # Internal SSL is disabled, since its managed via haproxy
  class { 'elasticsearch' :
    manage_repo       => true,
    oss               => $oss,
    secrets           => $secrets,
    keystore_path     => '/etc/elasticsearch/elasticsearch.keystore',
    autoupgrade       => false,
    config            => $instances,
    jvm_options       => [
      "-Xms${_es_heap_size_g}g",
      "-Xmx${_es_heap_size_g}g",
    ],
    restart_on_change => false,
    require           => Class['profile::java'],
    version           => $version,
    datadir           => $datadir,
  }

  # Elastic Plugins
  $plugins.each |$plugin, $opt| {
    elasticsearch::plugin { $plugin :
      * => $opt,
    }
  }

  # Logrotate Rule
  logrotate::rule { 'elasticsearch':
    ensure        => 'present',
    path          => [
      '/var/log/elasticsearch/*.log',
    ],
    rotate_every  => 'daily',
    rotate        => 31,
    compress      => true,
    delaycompress => true,
    missingok     => true,
  }
}
