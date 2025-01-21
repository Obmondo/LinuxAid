# InfluxDB
class profile::influxdb (
  Stdlib::IP::Address $ipaddress = '0.0.0.0',
  Stdlib::Port        $port      = 4242,
) {

  # FIXME: EnableIT-specific parts should be removed

  $opentsdb_config = {
    'default' => {
      'enabled'           => true, # not default
      'bind-address'      => "${ipaddress}:${port}",
      'database'          => 'obmondo_customers',
      'retention-policy'  => '',
      'consistency-level' => 'one',
      'tls-enabled'       => false,
      'certificate'       => '/etc/ssl/influxdb.pem',
      'log-point-errors'  => true,
      'batch-size'        => 1000,
      'batch-pending'     => 5,
      'batch-timeout'     => '1s'
    }
  }

  class { '::influxdb' :
    version         => '1.7.2-1',
    manage_repos    => true,
    opentsdb_config => $opentsdb_config,
  }

  firewall {
    default:
      proto => ['tcp'],
      jump  => 'accept',
      ;

    '100 allow influxdb connections':
      dport       => [$port],
      destination => $ipaddress,
      ;

    '100 allow influxdb-api':
      dport  => 8086,
      ;
    '100 allow influxdb api proxy':
      dport  => 9094,
      ;
  }

  package { 'obmondo-influxdb-client-proxy-internal':
    ensure => 'latest',
  }

  service { 'influxdb-client-proxy':
    ensure  => 'running',
    enable  => true,
    require => Package['obmondo-influxdb-client-proxy-internal'],
  }
}
