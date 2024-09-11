# Prometheus Server
# https://prometheus.io/blog/2021/11/16/agent/
# https://promlabs.com/blog/2022/12/15/understanding-duplicate-samples-and-out-of-order-timestamp-errors-in-prometheus/
class common::monitor::prom::server (
  Eit_types::Version   $version,
  Array[Hash]          $collect_scrape_jobs,
  Stdlib::Absolutepath $config_dir,

  Eit_types::IPPort $listen_address,

  Boolean $enable = $common::monitor::enable,
) {

  include common::monitor::prom

  Exec {
    noop => false,
  }

  File {
    noop => false,
  }

  file { '/opt/obmondo/prometheus':
    ensure  => directory,
    owner   => 'prometheus',
    group   => 'prometheus',
    require => User['prometheus'],
    notify  => Service['prometheus'],
  }

  $customer_id = $facts.dig('obmondo', 'customerid')
  $scrape_port = Integer($listen_address.split(':')[1])
  $scrape_host = $::trusted['certname']

  # Agent Mode, means no local storage on the node.
  class { 'prometheus::server':
    version                        => $version,
    storage_retention              => false,
    localstorage                   => false,
    collect_scrape_jobs            => $collect_scrape_jobs,
    collect_tag                    => $::trusted['certname'],
    extra_groups                   => ['obmondo'],
    include_default_scrape_configs => false,
    config_dir                     => $config_dir,
    manage_config_dir              => true,
    install_method                 => 'package',
    restart_on_change              => true,
    package_name                   => 'obmondo-prometheus',
    bin_dir                        => '/opt/obmondo/bin',
    extra_options                  => "--web.listen-address=${listen_address} --enable-feature=agent --storage.agent.path=/opt/obmondo/prometheus", #lint:ignore:140chars
    scrape_configs                 => [{
      job_name        => 'prometheus',
      scrape_interval => '10s',
      scrape_timeout  => '10s',
      static_configs  => [
        targets       => [
          "${scrape_host}:${scrape_port}",
        ],
        labels        => {
          alias => $trusted['certname'],
        },
      ],
    }],
    remote_write_configs           => [{
      url                   => "https://prometheus.obmondo.com/${customer_id}/api/v1/write",
      tls_config            => {
        cert_file => $::facts['hostcert'],
        key_file  => $::facts['hostprivkey'],
      },
      write_relabel_configs => [
        {
          source_labels => ['__name__'],
          regex         => 'go_gc_.*',
          action        => 'drop',
        },
        {
          source_labels => ['instance'],
          regex         => '(.*):(.*)',
          target_label  => 'certname',
          replacement   => '$1',
        },
        # Send only those metrics if instance ID matches the customer_id, otherwise drop the metrics
        {
          source_labels => ['certname'],
          regex         => "(.*).${customer_id}",
          action        => 'keep',
        },
      ],
    }],
  }

  # Build threshold records
  Monitor::Threshold <<| tag == $::trusted['certname'] |>>
  Monitor::Alert <<| tag == $::trusted['certname'] |>>
}
