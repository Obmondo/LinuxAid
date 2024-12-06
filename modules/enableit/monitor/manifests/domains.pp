# Monitor domains will monitor cert expiry and status code
define monitor::domains (
  Boolean       $enable      = true,
  Stdlib::Fqdn  $domain      = $title,
  Integer[1,30] $expiry_days = 30,
) {

  @@monitor::threshold { "monitor::domains::expiry::${domain}":
    enable => $enable,
    record => 'monitor::domains::cert_expiry_days',
    tag    => $::trusted['certname'],
    labels => {
      'domain' => $domain,
    },
    expr   => $expiry_days,
  }

  @@monitor::alert { "monitor::domains::cert_expiry::${domain}":
    enable   => $enable,
    alert_id => 'monitor::domains::cert_expiry',
    tag      => $::trusted['certname'],
  }

  @@monitor::alert { "monitor::domains::status::${domain}":
    enable   => $enable,
    alert_id => 'monitor::domains::status',
    tag      => $::trusted['certname'],
  }

}
