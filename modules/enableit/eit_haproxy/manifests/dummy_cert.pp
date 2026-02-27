# Haproxy Dummy Cert
class eit_haproxy::dummy_cert (
  Eit_haproxy::Domains $domains = {},
) {
  exec { 'ensure_ssl_private_dir':
    command => '/bin/mkdir -p /etc/ssl/private',
    creates => '/etc/ssl/private',
  }

  $domains.each | $group_name, $opts | {
    if $opts['force_https'] {
      # Make filename match what basic_config will use
      $_cert_filename = regsubst($group_name, /[^a-zA-Z0-9.-]/, '_', 'G')
      $_first_domain = $opts['domains'][0]

      exec { "generate_haproxy_dummy_cert_${_cert_filename}":
        command => "/usr/bin/openssl req -x509 -nodes -days 1 -newkey rsa:2048 -keyout /etc/ssl/private/${_cert_filename}.pem -out /etc/ssl/private/${_cert_filename}.pem -subj \"/CN=${_first_domain}\"",
        creates => "/etc/ssl/private/${_cert_filename}.pem",
        require => Exec['ensure_ssl_private_dir'],
      }
    }
  }

  # Always keep one default fallback cert just in case
  exec { 'generate_haproxy_dummy_cert':
    command => '/usr/bin/openssl req -x509 -nodes -days 1 -newkey rsa:2048 -keyout /etc/ssl/private/haproxy-dummy.pem -out /etc/ssl/private/haproxy-dummy.pem -subj "/CN=localhost"',
    creates => '/etc/ssl/private/haproxy-dummy.pem',
    require => Exec['ensure_ssl_private_dir'],
  }
}
