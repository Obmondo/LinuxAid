#
class mit_krb5::config::etc_services {

  $protocols = {
    'tcp' => 88,
    'udp' => 88,
  }

  ::etc_services { 'kerberos':
    protocols => $protocols,
    aliases   => [ 'kerberos5', 'krb5', 'kerberos-sec' ],
    comment   => 'Kerberos v5'
  }
}

# vim: tabstop=2 shiftwidth=2 softtabstop=2
