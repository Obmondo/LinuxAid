
# @summary Class for managing the ELK role
#
# @param clustername The name of the ELK cluster. Defaults to 'elkstack'.
#
# @param es_config Configuration hash for Elasticsearch. Defaults to an empty hash.
#
# @param es_version The version of Elasticsearch to use. Defaults to undef.
#
# @param es_datadir The absolute path for Elasticsearch data directory. Defaults to '/var/lib/elasticsearch/data'.
#
# @param cluster_hosts An array of IP addresses for the Elasticsearch cluster hosts. Defaults to the node's IP address.
#
# @param nxlog_windowseventlog If true, enables nxlog for Windows Event Log. Defaults to false.
#
# @param nxlog_ssl_windowseventlog If true, enables SSL for nxlog Windows Event Log. Defaults to false.
#
# @param nxlog_json If true, enables JSON logging for nxlog. Defaults to false.
#
# @param nxlog_ssl_json If true, enables SSL for nxlog JSON logging. Defaults to false.
#
# @param nginx_cfg_append Additional configuration for Nginx. Defaults to an empty hash.
#
# @param nginx_ssl_mode Defines the SSL mode for Nginx. Defaults to 'force'.
#
# @param ssl_cert The path to the SSL certificate. Defaults to undef.
#
# @param ssl_key The path to the SSL key. Defaults to undef.
#
# @param install_cerebro If true, installs Cerebro management UI. Defaults to true.
#
# @param enable_redis If true, enables Redis integration. Defaults to true.
#
# @param redis_datadir The absolute path for Redis data directory. Defaults to '/var/lib/redis'.
#
# @param redis_bind The addresses Redis will bind to. Defaults to '127.0.0.1'.
#
# @param redis_port The port on which Redis listens. Defaults to 6379.
#
# @param logstash_redis_to_es_workers Number of workers for Logstash to Redis to Elasticsearch pipeline. Defaults to undef.
#
# @param install_search_guard If true, installs Search Guard for security features. Defaults to false.
#
# @param curator If true, enables Curator for log management. Defaults to false.
#
# @param curator_delete_days Number of days to keep logs before deletion by Curator. Defaults to 7.
#
# @groups elasticsearch clustername, es_config, es_version, es_datadir, cluster_hosts
#
# @groups nxlog nxlog_windowseventlog, nxlog_ssl_windowseventlog, nxlog_json, nxlog_ssl_json
#
# @groups nginx nginx_cfg_append, nginx_ssl_mode, ssl_cert, ssl_key
#
# @groups cerebro install_cerebro
#
# @groups redis enable_redis, redis_datadir, redis_bind, redis_port
#
# @groups curator_tasks curator, curator_delete_days
#
# @groups additional logstash_redis_to_es_workers, install_search_guard
#
class role::monitoring::elk (
  Pattern[/[A-Za-z0-9_.-]+/] $clustername                         = 'elkstack',
  Hash[String, Data] $es_config                                   = {},
  Variant[Pattern[/\d\.\d\.\d/], Enum['2.x', '5.x']] $es_version  = undef,
  Stdlib::Absolutepath $es_datadir                                = '/var/lib/elasticsearch/data',
  Array[Eit_types::IP] $cluster_hosts                             = [$facts['networking']['ip']],
  Boolean $nxlog_windowseventlog                                  = false,
  Boolean $nxlog_ssl_windowseventlog                              = false,
  Boolean $nxlog_json                                             = false,
  Boolean $nxlog_ssl_json                                         = false,
  Hash $nginx_cfg_append                                          = {},
  Variant[Boolean, Enum['force']] $nginx_ssl_mode                 = 'force',
  Optional[Stdlib::Absolutepath] $ssl_cert                        = undef,
  Optional[Stdlib::Absolutepath] $ssl_key                         = undef,
  Boolean $install_cerebro                                        = true,
  Boolean $enable_redis                                           = true,
  Stdlib::Absolutepath $redis_datadir                             = '/var/lib/redis',
  Array[Variant[Eit_types::IPPort, Eit_types::IP], 1] $redis_bind = ['127.0.0.1'],
  Stdlib::Port $redis_port                                        = 6379,
  Optional[Integer] $logstash_redis_to_es_workers                 = undef,
  Boolean $install_search_guard                                   = false,
  Boolean $curator                                                = false,
  Integer $curator_delete_days                                    = 7,
) inherits ::role::monitoring {

  class { 'profile::elk':
    clustername               => $clustername,
    es_version                => $es_version,
    es_config                 => $es_config,
    es_datadir                => $es_datadir,
    cluster_hosts             => $cluster_hosts,
    nxlog_windowseventlog     => $nxlog_windowseventlog,
    nxlog_ssl_windowseventlog => $nxlog_ssl_windowseventlog,
    nxlog_json                => $nxlog_json,
    nxlog_ssl_json            => $nxlog_ssl_json,
    nginx_cfg_append          => $nginx_cfg_append,
    nginx_ssl_mode            => $nginx_ssl_mode,
    ssl_cert                  => $ssl_cert,
    ssl_key                   => $ssl_key,
    install_cerebro           => $install_cerebro,
    enable_redis              => $enable_redis,
    redis_datadir             => $redis_datadir,
    redis_bind                => $redis_bind,
    redis_port                => $redis_port,
    curator                   => $curator,
    curator_delete_days       => $curator_delete_days,
  }
}
