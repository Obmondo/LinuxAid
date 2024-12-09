# Manual certificate
# TODO: lets not accept expired cert from users.
# need to update the underlying module
# openssl::cert_date_valid($_cert_file)
define profile::certs::manual (
  String               $key,
  String               $cert,
  Stdlib::Absolutepath $base_dir_parts,
  Stdlib::Absolutepath $base_dir_combined,

  Stdlib::Fqdn         $domain = $title,
  Optional[String]     $ca     = undef,
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

  monitor::domains { $domain:
    enable => true,
  }

}
