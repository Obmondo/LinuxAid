# ELK profile
class profile::elk (
  Optional[Eit_types::SimpleString] $es_instance_name             = undef,
  Hash[String, Data] $es_config                                   = {},
  Variant[Pattern[/\d\.\d\.\d/], Enum['2.x', '5.x']] $es_version  = undef,
  Pattern[/[A-Za-z0-9_.-]+/] $clustername                         = 'elkstack',
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
  Boolean $install_riemann                                        = true,
  Boolean $curator                                                = false,
  Integer $curator_delete_days                                    = 7,
) {

  $_es_instance_name = pick($es_instance_name, "es-${facts['networking']['hostname']}")
  $_es_service_name = "elasticsearch-${_es_instance_name}"
  $_ssl = $nginx_ssl_mode in [true, 'force']

  if $_ssl {
    if !$ssl_key or !$ssl_cert {
      fail('Need $ssl_key and $ssl_cert')
    }
  }

  # Elastic Curator
  if $curator {
    class { '::profile::elastic::curator':
      delete_since => $curator_delete_days,
    }
  }

  # ES setup
  class { 'profile::db::elasticsearch':
    version       => $es_version,
    datadir       => $es_datadir,
    cluster_hosts => $cluster_hosts,
    instances     => {
      $_es_instance_name => {
        config => stdlib::merge({
          'cluster.name'                     => $clustername,
          'network.host'                     => ['_local_', '_site_'],
          'discovery.zen.ping.unicast.hosts' => $cluster_hosts,
        }, $es_config),
      },
    },
  }

  # Logstash setup
  class { '::profile::elastic::logstash':
    ensure      => true,
    manage_repo => false,
    version     => $es_version,
  }

  logstash::configfile { 'nxlog_json_to_redis':
    content => epp('profile/elk/logstash/nxlog_json_to_redis.conf.epp', {
      input_port => 5140,
      redis_port => $redis_port,
    }),
  }

  logstash::configfile { 'redis_to_es':
    content => epp('profile/elk/logstash/redis_to_es.conf.epp', {
      redis_port => $redis_port,
    }),
  }

  # class { 'kibana': }

  $_ssl_port = $_ssl ? {
    true  => 443,
    false => undef,
  }
  $_listen_port = $_ssl ? {
    true  => $_ssl_port,
    false => 80,
  }

  $_ssl_only = $nginx_ssl_mode == 'force'

  if $facts['selinux'] {
    selinux::port { 'allow-nginx-access-kibana-server':
      context  => 'http_port_t',
      protocol => 'tcp',
      port     => 5601,
    }
  }

  $_http_server_name = "kibana.${facts['networking']['hostname']}"

  class { 'nginx':
    confd_only        => true,
    confd_purge       => true,
    server_purge      => true,
    nginx_cfg_prepend => {
      include => [
        '/etc/nginx/modules-enabled/*.conf',
      ],
    },
  }

  nginx::resource::server { $_http_server_name:
    ssl                  => $_ssl,
    ssl_port             => $_ssl_port,
    listen_port          => $_listen_port,
    server_cfg_append    => $nginx_cfg_append,
    ssl_cert             => $ssl_cert,
    ssl_key              => $ssl_key,
    proxy                => 'http://localhost:5601',
    use_default_location => true,
  }

  nginx::resource::location { 'es':
    server              => $_http_server_name,
    ssl                 => $_ssl,
    ssl_only            => $_ssl_only,
    location            => '~ ^/es/.*$',
    proxy               => 'http://localhost:9200',
    location_cfg_append => {
      rewrite => ' ^/es/(.*) /$1 break',
    },
  }

  nginx::resource::location { 'status':
    server              => $_http_server_name,
    ssl                 => $_ssl,
    ssl_only            => $_ssl_only,
    location            => '~ ^/status/.*$',
    www_root            => '/var/www/status',
    location_cfg_append => {
      rewrite => ' ^/status/(.*) /$1 break',
    },
    require             => File['/var/www/status'],
  }

  file { '/var/www/status':
    ensure   => directory,
    mode     => 'ug+w,a=rx',
    group    => 'riemann',
    selrange => 's0',
    selrole  => 'object_r',
    seltype  => 'httpd_sys_content_t',
  }

  if $install_cerebro {
    class { '::profile::cerebro':
      es_service_name => $_es_service_name,
      selinux         => true,
    }

    nginx::resource::location { 'es-cerebro':
      server              => $_http_server_name,
      ssl                 => $_ssl,
      ssl_only            => $_ssl_only,
      location            => '~ ^/cerebro/.*$',
      proxy               => 'http://localhost:9000',
      location_cfg_append => {
        rewrite => ' ^/cerebro/(.*) /$1 break',
      },
    }
  }

  firewall_multi {
    default:
      ensure   => present,
      proto    => 'tcp',
      jump     => 'accept',
      protocol => ['ip6tables', 'iptables'],
    ;

    '000 allow nxlog' :
      ensure => ensure_present($nxlog_windowseventlog),
      dport  => 5140,
    ;

    '001 allow http/https':
      dport => [80,443],
    ;
  }

  # Setup Redis
  if $enable_redis {
    # FIXME: Use the bool flag as `ensure`
    # TODO: move to upstream redis module ?
    class { 'profile::redis' :
      bind    => $redis_bind,
      datadir => $redis_datadir,
    }
  }

  # Setup Riemann
  if $install_riemann {
    # Setup logstash plugin
    logstash::plugin { 'logstash-output-riemann':
      ensure  => ensure_present($install_riemann),
    }

    class { '::profile::monitoring::riemann':
      riemann_dash => true,
      tools        => true,
    }

    nginx::resource::location {
      default:
        server   => $_http_server_name,
        ssl      => $_ssl,
        ssl_only => $_ssl_only,
        ;

      'es-riemann-dash':
        location            => '~ ^/riemann-dash/.*$',
        proxy               => 'http://localhost:4567',
        location_cfg_append => {
          rewrite => ' ^/riemann-dash/(.*) /$1 break',
        },
        ;

      'es-riemann':
        location            => '~ ^/riemann/.*$',
        proxy               => 'http://localhost:5556',
        location_cfg_append => {
          rewrite            => ' ^/riemann/(.*) /$1 break',
          proxy_http_version => '1.1',
          proxy_set_header   => [
            'Upgrade $http_upgrade',
            'Connection "upgrade"',
          ],
        },
    }
  }
}
