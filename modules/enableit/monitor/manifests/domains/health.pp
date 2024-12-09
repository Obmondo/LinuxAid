# Monitor domains health
class monitor::domains::health (
  Boolean $enable = true,
) {

  @@monitor::alert { 'monitor::domains::cert_expiry':
    enable => $enable,
    tag    => $::trusted['certname'],
  }

  @@monitor::alert { 'monitor::domains::status':
    enable => $enable,
    tag    => $::trusted['certname'],
  }
}
