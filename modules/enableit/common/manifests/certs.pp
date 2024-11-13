# add custom certs and ca certs
class common::certs (
  Stdlib::Absolutepath $__base_dir,
  Hash[Stdlib::Fqdn, Struct[{
    key  => String,
    cert => String,
    ca   => Optional[String],
  }]] $manual = {},
  Hash[String, Struct[{
    ensure => Eit_types::Cert::Ensure,
    source => String,
  }]] $ca_certs = {},
) {
  Package {
    noop => false,
  }

  File {
    noop => false,
  }

  include ::trusted_ca
  include ::common::certs::letsencrypt

  if $manual.size {
    $_base_dir_parts = "${__base_dir}/parts"
    $_base_dir_combined = "${__base_dir}/combined"

    file { [$__base_dir, $_base_dir_combined, $_base_dir_parts]:
      ensure  => 'directory',
      owner   => 'root',
      group   => 'root',
      mode    => '0700',
      recurse => true,
      purge   => true,
    }
  }

  $manual.each |$_name, $_values| {
    # Get only the first bit of the domain name to keep dir name smaller
    # and to keep the old way of manual certs, since earlier we were only
    # accepting string and a not a FQDN
    $x_name = regsubst($_name, '^(\w+)(.*)$', '\1')
    profile::certs::manual { $x_name:
      base_dir_parts    => $_base_dir_parts,
      base_dir_combined => $_base_dir_combined,
      domain            => $_name,
      *                 => $_values,
    }
  }

  $ca_certs.each |$_name, $params| {
    profile::certs::ca_cert { $_name:
      * => $params,
    }
  }
}
