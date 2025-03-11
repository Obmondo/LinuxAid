# Elasticsearch Business role.
#
# $_instance - allows overriding all instance settings -
#    This means all other settings (except $version and $java_*) will be ignored if you set it!
#
class role::db::elasticsearch (
  Eit_types::Version                  $version               = '7.10.2', # latest as on 16th Nov 2023
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
