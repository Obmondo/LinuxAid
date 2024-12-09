# Monitor domains will monitor cert expiry and status code
define monitor::domains (
  Boolean       $enable      = true,
  Integer[1,30] $expiry_days = 30,

  Variant[Stdlib::Fqdn, Stdlib::HttpUrl] $domain = $title,
) {

  include monitor::domains::health

  $job_name = 'probe_blackbox_domains'
  $collect_dir = '/etc/prometheus/file_sd_config.d'
  $_domain = regsubst($domain, '^(https?://)?([^/]+)(/.*)?$', '\2', 'G').split('/')[0]

  @@prometheus::scrape_job { $_domain :
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

  $blackbox_node = if $enable { lookup('common::monitor::exporter::blackbox::node') }

  # NOTE: skip deleting the files on the actual blackbox node
  if $blackbox_node != $trusted['certname'] {
    File <| title == "${collect_dir}/${job_name}_${_domain}.yaml" |> {
      ensure => absent
    }
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
}
