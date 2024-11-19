# Elasticsearch Kibana dashboard
#
# Generate the pem cert from the cert created by elasticsearch
# Get the password
# /usr/share/elasticsearch/bin/elasticsearch-keystore show xpack.security.http.ssl.keystore.secure_password
# openssl pkcs12 -in http.p12 -out http.pem -clcerts -nodes
# openssl pkcs12 -in http.p12 -out http.pem -nocerts -nodes
class profile::db::elasticsearch::kibana (
  Boolean             $manage           = $role::db::elasticsearch::kibana,
  Boolean             $oss              = $role::db::elasticsearch::oss,
  Boolean             $expose           = $role::db::elasticsearch::expose,
  Boolean             $ssl              = $role::db::elasticsearch::ssl,
  Stdlib::Fqdn        $host             = $role::db::elasticsearch::host,
  Eit_types::Version  $version          = $role::db::elasticsearch::version,
  Optional[String]    $ssl_combined_pem = $role::db::elasticsearch::ssl_combined_pem,
  Optional[Hash]      $elasticsearch    = $role::db::elasticsearch::kibana_elasticsearch,
  Array[Stdlib::Host] $nodes            = $role::db::elasticsearch::nodes,
  Optional[String]    $ca_cert          = $role::db::elasticsearch::ca_cert,
  Optional[String]    $kibana_username  = $role::db::elasticsearch::kibana_username,
  Optional[String]    $kibana_password  = $role::db::elasticsearch::kibana_password,
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
        }
      } + if $ssl {
        {
          https_0_0_0_0_443 => {
            'ports'     => [443],
            'ssl'       => true,
            'options'   => 'crt /etc/ssl/private/elasticsearch/combined.pem',
            'ipaddress' => '0.0.0.0',
          }
        }
      }.delete_undef_values

      # Setup haproxy https
      file {
        '/etc/ssl/private/elasticsearch':
          ensure => directory,
          owner  => 'root',
          group  => 'root',
          mode   => '0500',
          ;

        '/etc/ssl/private/elasticsearch/combined.pem':
          ensure  => present,
          content => $ssl_combined_pem,
          mode    => '0400',
          before  => Class['haproxy'],
          require => File['/etc/ssl/private/elasticsearch'],
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

  $etc_kibana = '/etc/kibana'

  file { "${etc_kibana}/certs" :
    ensure => directory,
    owner  => 'kibana',
    group  => 'kibana',
  }

  file { "${etc_kibana}/certs/http.crt":
    ensure  => 'file',
    content => $elasticsearch.dig('cert'),
    mode    => '0600',
    owner   => 'kibana',
    group   => 'kibana',
  }

  file { "${etc_kibana}/certs/http.key":
    ensure  => 'file',
    content => $elasticsearch.dig('key'),
    owner   => 'kibana',
    group   => 'kibana',
    mode    => '0400',
  }

  file { "${etc_kibana}/certs/http_ca.crt":
    ensure  => 'file',
    content => $ca_cert,
    owner   => 'kibana',
    group   => 'kibana',
    mode    => '0400',
  }

  $elasticsearch_hosts = $nodes.map |$node| {
    "https://${node}:9200"
  }

  apt::pin { pin_kibana:
    packages => 'kibana',
    version  => $version,
    priority => '1001',
  }

  class { 'kibana':
    ensure => $version,
    oss    => $oss,
    config => {
      'elasticsearch.hosts'                      => $elasticsearch_hosts,
      'server.ssl.enabled'                       => false,
      'elasticsearch.username'                   => $kibana_username,
      # # TODO: https://github.com/voxpupuli/puppet-kibana/issues/38
      'elasticsearch.password'                   => $kibana_password,
      'elasticsearch.ssl.verificationMode'       => 'full',
      'elasticsearch.ssl.certificate'            => "${etc_kibana}/certs/http.crt",
      'elasticsearch.ssl.certificateAuthorities' => [
        "${etc_kibana}/certs/http_ca.crt",
      ],
      'elasticsearch.ssl.key'                    => "${etc_kibana}/certs/http.key",
    },
  }
}
