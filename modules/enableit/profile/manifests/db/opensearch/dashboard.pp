# Opensearch Dashboard
class profile::db::opensearch::dashboard (
  Boolean            $manage           = $role::db::opensearch::dashboard,
  Boolean            $expose           = $role::db::opensearch::expose,
  Boolean            $ssl              = $role::db::opensearch::ssl,
  Stdlib::Fqdn       $host             = $role::db::opensearch::host,
  Eit_types::Version $version          = $role::db::opensearch::version,
  Optional[String]   $ssl_combined_pem = $role::db::opensearch::ssl_combined_pem,
) {
  if $expose {
    if $ssl {

      # Fail if ssl cert is not given, when ssl is enabled
      confine($ssl, !$ssl_combined_pem, 'if ssl is enabled, a ssl cert is required')

      $_binds = {
        https_0_0_0_0_80 => {
          'ports'     => [80],
          'ssl'       => false,
          'ipaddress' => '0.0.0.0',
        },
        https_0_0_0_0_443 => {
          'ports'     => [443],
          'ssl'       => true,
          'options'   => 'crt /etc/ssl/private/readthedocs/combined.pem',
          'ipaddress' => '0.0.0.0',
        }
      }

      # Setup haproxy https
      file {
        '/etc/ssl/private/opensearch':
          ensure => directory,
          owner  => 'root',
          group  => 'root',
          mode   => '0500',
          ;

        '/etc/ssl/private/opensearch/combined.pem':
          ensure  => present,
          content => $ssl_combined_pem,
          mode    => '0400',
          before  => Class['haproxy'],
          require => File['/etc/ssl/private/opensearch'],
          ;
      }
    } else {
      $_binds = {
        https_0_0_0_0_80 => {
          'ports'     => [80],
          'ssl'       => false,
          'ipaddress' => '0.0.0.0',
        },
      }
    }

    class { '::eit_haproxy::auto_config' :
      encryption_ciphers => 'strict',
      redirect_http      => $ssl,
      proxies            => {
        readthedocs_http => {
          letsencrypt   => false,
          mode          => 'http',
          binds         => $_binds,
          sites         => {
            readthedocs_http => {
                servers         => [
                  '127.0.0.1:5601',
                ],
                default_backend => true,
            },
          },
          extra_options => {
            option => ['forwardfor'],
          }
        }
      },
    }
  }

  class { 'opensearch_dashboards':
    version                   => $version,
    settings                  => {
      'opensearch.hosts' => [
        'http://127.0.0.1:9200',
      ],
    },
    restart_on_package_change => false,
    restart_on_config_change  => false,
  }
}
