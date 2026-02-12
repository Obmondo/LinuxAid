# @summary Class for managing monitoring of domains and certificate expiry
#
# @param enable Boolean flag to enable or disable the monitoring. Defaults to true.
#
# @param expiry_days Number of days before expiry to alert. Defaults to 25.
#
# @param domain The domain to monitor. Defaults to $title.
#
# @groups monitoring enable, expiry_days, domain
#
define monitor::domains (
  Boolean                     $enable      = true,
  Integer[1,25]               $expiry_days = 25,
  Eit_types::Monitor::Domains $domain      = $title,
) {

  include monitor::domains::health

  $job_name = 'probe_blackbox_domains'
  $collect_dir = '/etc/prometheus/file_sd_config.d'

  @@prometheus::scrape_job { $domain :
    job_name    => $job_name,
    tag         => [
      $trusted['certname'],
      $::obmondo['customer_id'],
    ],
    targets     => [$domain],
    noop        => false,
    labels      => { 'certname' => $trusted['certname'] },
    collect_dir => $collect_dir,
  }

  $blackbox_node = if $enable { lookup('common::monitor::exporter::blackbox::node') }
  # NOTE: skip deleting the files on the actual blackbox node
  if $blackbox_node != $trusted['certname'] {
    File <| title == "${collect_dir}/${job_name}_${domain}.yaml" |> {
      ensure => absent
    }
  }

  @@monitor::threshold { "monitor::domains::expiry::${domain}" :
    enable => $enable,
    record => 'monitor::domains::cert_expiry_days',
    tag    => $trusted['certname'],
    labels => {
      'domain' => $domain,
    },
    expr   => $expiry_days,
  }
}
