# == Define: ca
#
# This define installs individual root CAs
#
#
# === Parameters
#
# [*source*]
#   Path to the certificate PEM.
#   Must specify either content or source.
#
# [*content*]
#   Content of certificate in PEM format.
#   Must specify either content or source.
#
# [*install_path*]
#   Location to install trusted certificates
#
# [*certfile_suffix*]
#   The suffix of the certificate to install.
#   Default is OS/Distribution dependent, i.e. 'crt' or 'pem'
#
# === Examples
#
# * Installation:
#     class { 'trusted_ca': }
#
#     trusted_ca::ca { 'example.org.local':
#       source  => puppet:///data/ssl/example.com.pem
#     }
#
#     trusted_ca::ca { 'example.net.local':
#       content  => hiera("example-net-x509")
#     }
#
# === Authors
#
# * Justin Lambert <mailto:jlambert@eml.cc>
#
define trusted_ca::ca (
  Optional[String] $source = undef,
  Optional[Pattern['^[A-Za-z0-9+/\n=-]+$']] $content = undef,
  Stdlib::Absolutepath $install_path = $trusted_ca::install_path,
  String $certfile_suffix = $trusted_ca::certfile_suffix,
) {
  if ! defined(Class['trusted_ca']) {
    fail('You must include the trusted_ca base class before using any trusted_ca defined resources')
  }

  if $source and $content {
    fail('You must not specify both $source and $content for trusted_ca defined resources')
  }

  if $name =~ Pattern["\\.${certfile_suffix}$"] {
    $_name = $name
  } else {
    $_name = "${name}.${certfile_suffix}"
  }

  if $source {
    file { "${install_path}/${_name}":
      ensure => 'file',
      source => $source,
      notify => Exec["validate ${install_path}/${_name}"],
      mode   => '0644',
      owner  => 'root',
      group  => 'root',
    }
  } elsif $content {
    file { "${install_path}/${_name}":
      ensure  => 'file',
      content => $content,
      notify  => Exec["validate ${install_path}/${_name}"],
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
    }
  } else {
    fail('You must specify either $source or $content for trusted_ca defined resources')
  }

  # This makes sure the certificate is valid
  exec { "validate ${install_path}/${_name}":
    command     => "openssl x509 -in ${install_path}/${_name} -noout",
    logoutput   => on_failure,
    path        => $trusted_ca::path,
    notify      => Exec['update_system_certs'],
    returns     => 0,
    refreshonly => true,
  }
}
