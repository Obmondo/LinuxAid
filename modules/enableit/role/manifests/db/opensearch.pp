
# @summary Opensearch Business role.
#
# @param ssl_combined_pem The path to the combined SSL PEM file. Defaults to undef.
#
# @param version The version of Opensearch. Defaults to '2.11.0'.
#
# @param es_heap_size_pct The percentage of heap size for Elasticsearch. Defaults to 50.
#
# @param es_heap_size_max_gb The maximum heap size in GB for Elasticsearch. Defaults to 31.
#
# @param cerebro Whether to include Cerebro in the deployment. Defaults to false.
#
# @param host The FQDN of the Opensearch host.
#
# @param access_9200_port_from The hosts allowed to access the Opensearch 9200 port. Defaults to an empty array.
#
# @param nodes The list of Opensearch nodes.
#
# @param datadir The directory for Opensearch data. Defaults to '/var/lib/opensearch'.
#
# @param cluster_name The name of the Opensearch cluster. Defaults to 'opensearch-cluster'.
#
# @param curate_filters The filters for curating data. Defaults to an empty hash.
#
# @param ssl Whether to enable SSL. Defaults to false.
#
# @param dashboard Whether to include the Opensearch Dashboard. Defaults to false.
#
# @param expose Whether to expose the service. Defaults to false.
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
