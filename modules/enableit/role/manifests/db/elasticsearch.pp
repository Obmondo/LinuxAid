
# @summary Elasticsearch Business role.
#
# @param version The version of Elasticsearch to use. Defaults to '7.10.2'.
#
# @param es_heap_size_pct The heap size percentage. Defaults to 50.
#
# @param es_heap_size_max_gb The maximum heap size in gigabytes. No default provided.
#
# @param cerebro Include Cerebro support. Defaults to false.
#
# @param kibana Include Kibana support. Defaults to false.
#
# @param cache_only_node Indicator for whether this is a cache-only node. Defaults to false.
#
# @param host The host for Elasticsearch. No default provided.
#
# @param access_9200_port_from A list of hosts allowed to access the 9200 port. Defaults to an empty array.
#
# @param plugins A hash of plugins to install. Defaults to an empty hash.
#
# @param nodes An array of nodes in the Elasticsearch cluster. No default provided.
#
# @param datadir The directory for Elasticsearch data. Defaults to '/var/lib/elasticsearch'.
#
# @param cluster_name The name of the Elasticsearch cluster. Defaults to 'elasticsearch-cluster'.
#
# @param curate_filters A hash of filters for curating data. Defaults to an empty hash.
#
# @param security Enable security features. Defaults to false.
#
# @param ssl Enable SSL support. Defaults to false.
#
# @param oss Use the OSS version of Elasticsearch. Defaults to true.
#
# @param expose Expose the Elasticsearch service. Defaults to false.
#
# @param ssl_combined_pem Optional combined PEM file for SSL. Defaults to undef.
#
# @param secrets Optional hash of secrets. Defaults to undef.
#
# @param kibana_elasticsearch Optional settings for Kibana's Elasticsearch connection. Defaults to undef.
#
# @param http Optional HTTP settings. Defaults to undef.
#
# @param transport Optional transport settings. Defaults to undef.
#
# @param ca_cert Optional CA certificate for SSL. Defaults to undef.
#
# @param kibana_username Optional username for Kibana. Defaults to undef.
#
# @param kibana_password Optional password for Kibana. Defaults to undef.
#
class role::db::elasticsearch (
  Eit_types::Version                  $version               = '7.10.2',
  Eit_types::Percentage               $es_heap_size_pct      = 50,
  Variant[Integer[1,31], Float[1,31]] $es_heap_size_max_gb   = 31,
  Boolean                             $cerebro               = false,
  Boolean                             $kibana                = false,
  Boolean                             $cache_only_node       = false,
  Stdlib::Fqdn                        $host,
  Optional[Array[Stdlib::Host]]       $access_9200_port_from = [],
  Optional[Hash]                      $plugins               = {},
  Array[Stdlib::Host]                 $nodes,
  Stdlib::Unixpath                    $datadir               = '/var/lib/elasticsearch',
  Eit_types::SimpleString             $cluster_name          = 'elasticsearch-cluster',
  Hash[Eit_types::SimpleString, Hash] $curate_filters        = {},
  Boolean                             $security              = false,
  Boolean                             $ssl                   = false,
  Boolean                             $oss                   = true,
  Boolean                             $expose                = false,
  Optional[String]                    $ssl_combined_pem      = undef,
  Optional[Hash]                      $secrets               = undef,
  Optional[Hash]                      $kibana_elasticsearch  = undef,
  Optional[String]                    $http                  = undef,
  Optional[String]                    $transport             = undef,
  Optional[String]                    $ca_cert               = undef,
  Optional[String]                    $kibana_username       = undef,
  Optional[String]                    $kibana_password       = undef,
) inherits ::role::db {

  confine($facts['os']['family'] != 'Debian', 'Only Debian-based distributions are supported')

  contain profile::db::elasticsearch

  # Cerebro
  if $cerebro {
    contain profile::db::elasticsearch::cerebro
  }

  # Kibana
  if $kibana {
    contain profile::db::elasticsearch::kibana
  }
}
