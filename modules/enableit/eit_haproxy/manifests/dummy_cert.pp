# Haproxy Dummy Cert
class eit_haproxy::dummy_cert (
  Eit_haproxy::Domains $domains = {},
) {
  $_bootstrap_dir = '/etc/ssl/private/haproxy-bootstrap'
  $_snakeoil_cert = '/etc/ssl/certs/ssl-cert-snakeoil.pem'
  $_snakeoil_key = '/etc/ssl/private/ssl-cert-snakeoil.key'
  $_pem_validate_cmd = eit_haproxy::pem_validate_cmd()

  file { '/etc/ssl/private':
    ensure => directory,
    mode   => '0710',
  }

  file { $_bootstrap_dir:
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    recurse => true,
    purge   => true,
    force   => true,
    require => File['/etc/ssl/private'],
  }

  file { $_snakeoil_cert:
    ensure  => file,
    require => Package['ssl-cert'],
  }

  file { $_snakeoil_key:
    ensure  => file,
    require => Package['ssl-cert'],
  }

  $_managed_domain_cert_files = $domains.filter |$group_name, $opts| {
    $opts['force_https']
  }.map |$group_name, $opts| {
    $_cert_filename = regsubst($group_name, /[^a-zA-Z0-9.-]/, '_', 'G')
    "${_bootstrap_dir}/${_cert_filename}.pem"
  }

  $_managed_domain_cert_files.each |$cert_file| {
    file { $cert_file:
      ensure       => file,
      owner        => 'root',
      group        => 'root',
      mode         => '0600',
      source       => ["file://${_snakeoil_cert}", "file://${_snakeoil_key}"],
      sourceselect => 'all',
      validate_cmd => $_pem_validate_cmd,
      require      => [
        File[$_bootstrap_dir],
        File[$_snakeoil_cert],
        File[$_snakeoil_key],
      ],
    }
  }

  # Always keep one default fallback cert just in case
  file { "${_bootstrap_dir}/haproxy-dummy.pem":
    ensure       => file,
    owner        => 'root',
    group        => 'root',
    mode         => '0600',
    source       => ["file://${_snakeoil_cert}", "file://${_snakeoil_key}"],
    sourceselect => 'all',
    validate_cmd => $_pem_validate_cmd,
    require      => [
      File[$_bootstrap_dir],
      File[$_snakeoil_cert],
      File[$_snakeoil_key],
    ],
  }
}
