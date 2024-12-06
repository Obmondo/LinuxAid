# Monitor domains will monitor cert expiry and status code
define monitor::domains (
  Boolean       $enable      = true,
  Integer[1,30] $expiry_days = 30,

  Variant[Stdlib::Fqdn, Stdlib::HttpUrl] $domain = $title,
) {

  $job_name = 'probe_domains_blackbox'
  $collect_dir = '/etc/prometheus/file_sd_config.d'
  $_domain = regsubst($domain, '^(https?://)?([^/]+)(/.*)?$', '\2', 'G').split('/')[0]

  @@prometheus::scrape_job { "blackbox_haproxy_${trusted['certname']}_${_domain}" :
    job_name    => $job_name,
    tag         => [
      $trusted['certname'],
      $facts.dig('obmondo', 'customerid')
    ],
    targets     => [$_domain],
    noop        => false,
    labels      => { 'certname' => $trusted['certname'] },
    collect_dir => $collect_dir,
  }

  File <| title == "${collect_dir}/${job_name}_blackbox_domain_${trusted['certname']}_${_domain}.yaml" |> {
    ensure => absent
  }

  @@monitor::threshold { "monitor::domains::expiry::${_domain}":
    enable => $enable,
    record => 'monitor::domains::cert_expiry_days',
    tag    => $::trusted['certname'],
    labels => {
      'domain' => $_domain,
    },
    expr   => $expiry_days,
  }

  @@monitor::alert { "monitor::domains::cert_expiry::${_domain}":
    enable   => $enable,
    alert_id => 'monitor::domains::cert_expiry',
    tag      => $::trusted['certname'],
  }

  @@monitor::alert { "monitor::domains::status::${_domain}":
    enable   => $enable,
    alert_id => 'monitor::domains::status',
    tag      => $::trusted['certname'],
  }
}
