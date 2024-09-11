# == Define: java
#
# This define installs certs to a java cacerts file
#
#
# === Parameters
#
# [*java_keystore*]
#   Location of java cacerts file
#   This must be specified - there is no default.
#
# [*source*]
#   Path to the certificate PEM.
#   Must specify either content or source.
#
# [*content*]
#   Content of certificate in PEM format.
#   Must specify either content or source.
#
#
# === Examples
#
# * Installation:
#     class { 'trusted_ca': }
#
#     trusted_ca::java { 'example.org.local':
#       source  => puppet:///data/ssl/example.com.pem
#     }
#
#     trusted_ca::java { 'example.net.local':
#       content  => hiera("example-net-x509")
#     }
#
# === Authors
#
# * Justin Lambert <mailto:jlambert@eml.cc>
#
define trusted_ca::java (
  Stdlib::Absolutepath $java_keystore,
  Optional[String] $source = undef,
  Optional[Pattern['^[A-Za-z0-9+/\n=-]+$']] $content = undef,
) {
  if ! defined(Class['trusted_ca']) {
    fail('You must include the trusted_ca base class before using any trusted_ca defined resources')
  }

  if $source and $content {
    fail('You must not specify both $source and $content for trusted_ca defined resources')
  }

  if $source {
    file { "/tmp/${name}-trustedca":
      ensure => 'file',
      source => $source,
      notify => Exec["validate /tmp/${name}-trustedca"],
      mode   => '0644',
      owner  => 'root',
      group  => 'root',
    }
  } elsif $content {
    file { "/tmp/${name}-trustedca":
      ensure  => 'file',
      content => $content,
      notify  => Exec["validate /tmp/${name}-trustedca"],
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
    }
  } else {
    fail('You must specify either $source or $content for trusted_ca defined resources')
  }

  # This makes sure the certificate is valid
  exec { "validate /tmp/${name}-trustedca":
    command     => "openssl x509 -in /tmp/${name}-trustedca -noout",
    logoutput   => on_failure,
    path        => $trusted_ca::path,
    notify      => Exec["import /tmp/${name}-trustedca to jks ${java_keystore}"],
    returns     => 0,
    refreshonly => true,
  }

  exec { "import /tmp/${name}-trustedca to jks ${java_keystore}":
    command   => "keytool -import -noprompt -trustcacerts -alias ${name} -file /tmp/${name}-trustedca -keystore ${java_keystore} -storepass changeit",
    cwd       => '/tmp',
    path      => $trusted_ca::path,
    logoutput => on_failure,
    unless    => "echo '' | keytool -list -keystore ${java_keystore} | grep -i ${name}",
    require   => File["/tmp/${name}-trustedca"],
  }
}
