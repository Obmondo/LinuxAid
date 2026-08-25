# Manual certificate
# TODO: lets not accept expired cert from users.
# need to update the underlying module
# openssl::cert_date_valid($_cert_file)
define profile::system::certs::manual (
  String               $key,
  String               $cert,
  Stdlib::Absolutepath $base_dir_parts,
  Stdlib::Absolutepath $base_dir_combined,

  Stdlib::Fqdn         $domain = $title,
  Optional[String]     $ca     = undef,

  Optional[Array[Stdlib::Port]] $ports = undef,
) {

  $_parts_dir     = "${base_dir_parts}/${name}"
  $_cert_file     = "${_parts_dir}/cert.pem"
  $_cert_key      = "${_parts_dir}/key.pem"
  $_cert_ca       = "${_parts_dir}/ca.pem"
  $_cert_combined = "${base_dir_combined}/${name}.pem"

  File {
    ensure => 'file',
    owner  => 'root',
    group  => 'root',
    mode   => '0400',
    noop   => false,
  }

  file { $_parts_dir:
    ensure => 'directory',
  }

  file {
    default:
      require => File[$_parts_dir],
      notify  => File[$_cert_combined],
    ;
    $_cert_file:
      content => "${cert}\n",
      mode    => '0600',
    ;
    $_cert_key:
      content => "${key}\n",
    ;
  }

  if $ca {
    file { $_cert_ca:
      content => "${ca}\n",
      require => File[$_parts_dir],
      notify  => File[$_cert_combined],
    }
  }

  $_cert_combined_parts = [
    $_cert_key,
    $_cert_file,
    if $ca {
      $_cert_ca
    },
  ].delete_undef_values

  $key_and_cert = join([$key, $cert], "\n")

  file { $_cert_combined:
    content => $key_and_cert,
  }

  # NOTE: monitor the domain this cert is *deployed* for, not the cert's CN.
  # The CN is only one of the names a cert carries and is deprecated as an
  # identifier; the hiera title is the name we actually serve on this host.
  # Casing is normalised because CAs emit whatever casing they were asked for.
  $_domain = downcase($domain)

  if $ports.empty {
    # NOTE: the scheme is required. Given a bare hostname, blackbox scores the
    # plain-HTTP request, so probe_http_ssl is 0 and fail_if_not_ssl marks the
    # probe failed - which silences cert expiry alerting for this domain even
    # though probe_ssl_earliest_cert_expiry is scraped fine.
    monitor::domains { $_domain:
      domain => "https://${_domain}",
    }
  } else {
    $ports.each |$port| {
      monitor::domains { "${_domain}_${port}":
        domain => "https://${_domain}:${port}",
      }
    }
  }

}
