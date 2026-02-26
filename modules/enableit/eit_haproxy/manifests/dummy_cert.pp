# Haproxy Dummy Cert
class eit_haproxy::dummy_cert {
  exec { 'ensure_ssl_private_dir':
    command => '/bin/mkdir -p /etc/ssl/private',
    creates => '/etc/ssl/private',
  }

  exec { 'generate_haproxy_dummy_cert':
    command => '/usr/bin/openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout /etc/ssl/private/haproxy-dummy.pem -out /etc/ssl/private/haproxy-dummy.pem -subj "/CN=localhost"',
    creates => '/etc/ssl/private/haproxy-dummy.pem',
    require => Exec['ensure_ssl_private_dir'],
  }
}
