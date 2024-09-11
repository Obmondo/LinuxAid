# Haproxy monitoring
class eit_haproxy::monitoring {
  # Haproxy Monitoring
  $facts.dig('haproxy_version').then |$_haproxy_version| {
    # if version is >= 2.0.0
    if versioncmp($_haproxy_version, '2.0.0') >= 0 {
      haproxy::listen { 'obmondo-monitoring':
        ipaddress => '127.254.254.254',
        ports     => '63661',
        mode      => 'http',
        options   => {
          'stats'        => 'enable',
          'http-request' => 'use-service prometheus-exporter if { path /metrics }',
        },
      }
    }
  }.lest || {
    haproxy::listen { 'obmondo-monitoring':
      ipaddress => '127.254.254.254',
      ports     => '63661',
      mode      => 'http',
      options   => {
        'stats' => 'enable',
      },
    }
  }
}
