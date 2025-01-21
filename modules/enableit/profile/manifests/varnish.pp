# Varnish Profile
class profile::varnish (
  String $backendip,
  Eit_types::UUID $secret,
  String $variant                   = 'default',
  Optional[String] $listen          = undef,
  Integer $backendport              = 80,
  Array[String] $adminlistens       = ['0.0.0.0'],
  Optional[Array[String]] $adminacl = undef,
  Array[String] $purgers            = [ 'localhost' ],
) {

  if ( ! defined (Firewall['000 allow http'] )) {
    firewall { '000 allow http':
      proto => 'tcp',
      dport => 80,
      jump  => 'accept',
    }
  }
  if ( $adminacl ) {
    profile::varnish::fwadmin { $adminacl: }
  }

  $_adminlistens = $adminacl ? {
    undef   => '',
    default => $adminlistens,
  }
  class { '::varnish':
    vcl          => "profile/${variant}.vcl",
    secret       => $secret,
    adminlistens => $_adminlistens,
    listen       => $listen,
  }

  $quoted_purgers = $purgers.map | $p | { "\"${p}\"" }
}
