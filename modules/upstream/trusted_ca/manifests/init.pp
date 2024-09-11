# == Class: trusted_ca
#
# This class installs additional trusted root CAs
#
#
# === Parameters
#
# None
#
#
# === Examples
#
# * Installation:
#
#     include trusted_ca
#     trusted_ca::ca { 'example.org.local':
#       source  => puppet:///data/ssl/example.com.pem
#     }
#
#
# === Authors
#
# * Justin Lambert <mailto:jlambert@eml.cc>
#
class trusted_ca (
  String $certificates_version = $trusted_ca::params::certificates_version,
  Variant[Array[String], String] $path = $trusted_ca::params::path,
  Stdlib::Absolutepath $install_path = $trusted_ca::params::install_path,
  String $update_command = $trusted_ca::params::update_command,
  String $certfile_suffix = $trusted_ca::params::certfile_suffix,
  String $certs_package = $trusted_ca::params::certs_package,
) inherits trusted_ca::params {
  stdlib::ensure_packages([$certs_package], { ensure => $certificates_version })

  exec { 'update_system_certs':
    command     => $update_command,
    path        => $path,
    logoutput   => on_failure,
    refreshonly => true,
  }
}
