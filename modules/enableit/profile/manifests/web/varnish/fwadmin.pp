# Varnish Firewall
define profile::varnish::fwadmin {
  if ( ! defined (Firewall["001 varnish adminacl ${name}"] )) {
    firewall { "001 varnish adminacl ${name}":
      proto  => 'tcp',
      source => $name,
      dport  => 6082,
      jump   => 'accept',
    }
  }
}
