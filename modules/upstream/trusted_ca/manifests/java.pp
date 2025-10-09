# @summary install certs to a java cacerts file
#
# @param java_keystore
#   Location of java cacerts file
#   This must be specified - there is no default.
#
# @param source
#   Path to the certificate PEM.
#   Must specify either content or source.
#
# @param content
#   Content of certificate in PEM format.
#   Must specify either content or source.
#
# @param filename
#   The intermediate filename to use
#
# @example Installation
#   include trusted_ca
#
#   trusted_ca::java { 'example.org.local':
#     source => 'puppet:///data/ssl/example.com.pem',
#   }
#
#   trusted_ca::java { 'example.net.local':
#     content  => lookup('example-net-x509'),
#   }
#
# @author Justin Lambert <mailto:jlambert@eml.cc>
#
define trusted_ca::java (
  Stdlib::Absolutepath $java_keystore,
  Optional[String] $source = undef,
  Optional[Pattern['^[A-Za-z0-9+/\n=-]+$']] $content = undef,
  Stdlib::Absolutepath $filename = "/tmp/${name}-trustedca",
) {
  if ! defined(Class['trusted_ca']) {
    fail('You must include the trusted_ca base class before using any trusted_ca defined resources')
  }

  if $source and $content {
    fail('You must not specify both $source and $content for trusted_ca defined resources')
  } elsif !$source and !$content {
    fail('You must specify either $source or $content for trusted_ca defined resources')
  }

  file { $filename:
    ensure       => 'file',
    source       => $source,
    content      => $content,
    mode         => '0644',
    owner        => 'root',
    group        => 'root',
    validate_cmd => '/usr/bin/openssl x509 -in %s -noout',
    notify       => Exec["import ${filename} to jks ${java_keystore}"],
  }

  exec { "import ${filename} to jks ${java_keystore}":
    command   => "keytool -import -noprompt -trustcacerts -alias ${name} -file ${filename} -keystore ${java_keystore} -storepass changeit",
    cwd       => '/tmp',
    path      => $trusted_ca::path,
    logoutput => on_failure,
    unless    => "echo '' | keytool -list -keystore ${java_keystore} | grep -i ${name}",
    require   => File["/tmp/${name}-trustedca"],
  }
}
