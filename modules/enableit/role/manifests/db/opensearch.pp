# Opensearch Business role.
#
# $_instance - allows overriding all instance settings -
#    This means all other settings (except $version and $java_*) will be ignored if you set it!
#
class role::db::opensearch (
  Optional[String]                    $ssl_combined_pem      = undef,
  Eit_types::Version                  $version               = '2.11.0',
  Eit_types::Percentage               $es_heap_size_pct      = 50,
  Variant[Integer[1,31], Float[1,31]] $es_heap_size_max_gb   = 31,
  Boolean                             $cerebro               = false,
  Stdlib::Fqdn                        $host,
  Optional[Array[Stdlib::Host]]       $access_9200_port_from = [],
  Array[Stdlib::Host]                 $nodes,
  Stdlib::Unixpath                    $datadir               = '/var/lib/opensearch',
  Eit_types::SimpleString             $cluster_name          = 'opensearch-cluster',
  Hash[Eit_types::SimpleString, Hash] $curate_filters        = {},
  Boolean                             $ssl                   = false,
  Boolean                             $dashboard             = false,
  Boolean                             $expose                = false,
) inherits ::role::db {

  contain profile::db::opensearch

  if $cerebro {
    contain profile::db::elasticsearch::cerebro
  }

  # Opensearch Dashboard
  if $dashboard {
    contain profile::db::opensearch::dashboard
  }

}
