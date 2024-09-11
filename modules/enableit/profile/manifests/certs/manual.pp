# Manual certificate
define profile::certs::manual (
  String               $key,
  String               $cert,
  Stdlib::Absolutepath $base_dir_parts,
  Stdlib::Absolutepath $base_dir_combined,

  Stdlib::Fqdn         $domain = $title,
  Optional[String]     $ca     = undef,
) {

  File {
    noop => false,
  }

  $_parts_dir     = "${base_dir_parts}/${name}"
  $_cert_file     = "${_parts_dir}/cert.pem"
  $_cert_key      = "${_parts_dir}/key.pem"
  $_cert_ca       = "${_parts_dir}/ca.pem"
  $_cert_combined = "${base_dir_combined}/${name}.pem"

  # TODO: lets not accept expired cert from users.
  # need to update the underlying module
  # openssl::cert_date_valid($_cert_file)

  file { $_parts_dir:
    ensure => 'directory',
  }

  File {
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0400',
    require => File[$_parts_dir],
    notify  => Exec["write combined cert ${name}"],
  }

  file { $_cert_file:
    content => "${cert}\n",
    mode    => '0600',
  }

  file { $_cert_key:
    content => "${key}\n",
  }

  if $ca {
    file { $_cert_ca:
      content => "${ca}\n",
    }
  }

  $_cert_combined_parts = [
    $_cert_key,
    $_cert_file,
    if $ca {
      $_cert_ca
    },
  ].delete_undef_values

  exec { "write combined cert ${name}":
    command     => "cat ${_cert_combined_parts.join(' ')} > ${_cert_combined}",
    path        => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    refreshonly => true,
    creates     => $_cert_combined,
    subscribe   => File[
      $_cert_file,
      $_cert_key,
      if $ca { $_cert_ca },
    ],
    require     => File[$base_dir_combined],
  }

  file { $_cert_combined:
    ensure => 'file',
  }

  monitor::domains::expiry { $domain:
    enable => true,
  }

}
