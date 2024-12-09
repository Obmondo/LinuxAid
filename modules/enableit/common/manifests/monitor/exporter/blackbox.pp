  # Prometheus Blackbox Exporter
class common::monitor::exporter::blackbox (
  Boolean              $enable,
  Stdlib::Port         $listen_port,
  Array[Variant[Stdlib::Fqdn, Stdlib::HttpUrl, Stdlib::HttpsUrl]]  $targets     = [],
  Boolean[false]       $noop_value  = false,
  Stdlib::Absolutepath $config_file = "${::common::monitor::exporter::config_dir}/blackbox.yml",
) {

  $blackbox_node = if $enable {lookup('common::monitor::exporter::blackbox::node') }
  $customer_id = $facts.dig('obmondo', 'customerid')

  Exec {
    noop => $noop_value,
  }

  File {
    noop => $noop_value,
  }

  include common::monitor::prom

  class { 'prometheus::blackbox_exporter':
    package_name      => 'obmondo-blackbox-exporter',
    package_ensure    => ensure_latest($enable),
    init_style        => if !$enable {'none'},
    user              => 'blackbox_exporter',
    group             => 'blackbox_exporter',
    service_enable    => $enable,
    service_ensure    => ensure_service($enable),
    manage_service    => $enable,
    restart_on_change => $enable,
    scrape_host       => $trusted['certname'],
    scrape_port       => $listen_port,
    extra_options     => "--web.listen-address='127.254.254.254:${listen_port}'",
    config_file       => $config_file,
    tag               => $::trusted['certname'],
    export_scrape_job => $enable,
    scrape_job_labels => { 'certname' => $::trusted['certname'] },
    modules           => {
      'http_2xx'    => {
        'prober'  => 'http',
        'timeout' => '10s',
        'http'    => {
          'fail_if_not_ssl'       => true,
          'preferred_ip_protocol' => 'ip4',
        },
      },
    }
  }

  # NOTE: This is a daemon-reload, which will do a daemon-reload in noop mode.
  # upstream module cant handle noop. (which is correct)
  Exec <| tag == 'systemd-blackbox_exporter.service-systemctl-daemon-reload' |> {
    noop => $noop_value,
  }

  if $targets.size > 0 {
    $targets.each |$domain| {
      monitor::domains { $domain: }
    }
  }

  # Collect all the resource only on the node where blackbox is enabled.
  # and collect resource only for their specific customer nodes
  if $blackbox_node == $trusted['certname'] {

    # Handle file resource under prometheus::scrape_job, so it can be created in noop mode
    # https://www.puppet.com/docs/puppet/7/lang_resources.html#lang_resource_syntax-adding-or-modifying-attributes
    File <| tag == 'prometheus::scrape_job' |> {
      noop => $noop_value,
    }

    Prometheus::Scrape_job <<| job_name == 'probe_domains_blackbox' and tag == $customer_id |>> {
      notify => Class['prometheus::service_reload'],
    }
  }
}
