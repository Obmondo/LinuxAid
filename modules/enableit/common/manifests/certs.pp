# @summary Class for managing common certificates and CA certificates
#
# @param __base_dir The absolute path to the base directory. This parameter is mandatory.
#
# @param manual A hash of manual certificates with domain names as keys and corresponding certificate details as values. Defaults to empty hash.
#
# @param ca_certs A hash of CA certificates with names as keys and their parameters as values. Defaults to empty hash.
#
# @param encrypt_params The list of params, which needs to be encrypted
#
# @groups directory_params __base_dir
#
# @groups manual_params manual, encrypt_params
#
# @groups ca_params ca_certs
#
class common::certs (
  Stdlib::Absolutepath $__base_dir,
  Hash[Stdlib::Fqdn, Struct[{
      key   => String,
      cert  => String,
      ca    => Optional[String],
      ports => Optional[Array[Stdlib::Port]],
  }]] $manual = {},
  Hash[String, Struct[{
      source  => Optional[Eit_Files::Source],
      content => Optional[String],
  }]] $ca_certs = {},
  Eit_types::Encrypt::Params $encrypt_params = [
    'manual.*.key',
    'manual.*.cert',
    'manual.*.ca',
  ]

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
    # Get only the first part of the domain name to keep directory name smaller
    # and to maintain compatibility with previous manual certs setup
    $x_name = regsubst($_name, '^(\w+)(.*)$', '\1')
    profile::certs::manual { $x_name:
      base_dir_parts    => $_base_dir_parts,
      base_dir_combined => $_base_dir_combined,
      domain            => $_name,
      *                 => $_values,
    }
    $_targets = $_values['port'] ? {
      Integer => "${_name}:${_values['port']}",
      default => $_name,
    }
  }
  $ca_certs.each |$_name, $params| {
    profile::certs::ca_cert { $_name:
      * => $params,
    }
  }
}
