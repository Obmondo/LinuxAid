#
class mit_krb5::config::etc_services {

  [ 'tcp', 'udp' ].each |String $protocol| {

    ::etc_services { "kerberos/${protocol}":
      port    => '88',
      aliases => [ 'kerberos5', 'krb5', 'kerberos-sec' ],
      comment => 'Kerberos v5'
    }

  }
}

# vim: tabstop=2 shiftwidth=2 softtabstop=2
