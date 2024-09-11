# SSL cert expiry check for prometheus.
# It will create the alert and threshold
# so prom rule can test the domain if its expired or not
define monitor::domains::expiry (
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
}
