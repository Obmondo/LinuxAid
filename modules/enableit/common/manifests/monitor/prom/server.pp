# @summary Class for managing the Prometheus server
#
# @param version The version of Prometheus to install. Must be a Eit_types::Version.
#
# @param collect_scrape_jobs An array of hashes defining scrape jobs to collect. Defaults to an empty array.
#
# @param config_dir The absolute path to the configuration directory. Must be a Stdlib::Absolutepath.
#
# @param listen_address The IP and port on which the server listens. Must be of type Eit_types::IPPort.
#
# @param enable Boolean to enable or disable the monitoring. Defaults to true.
#
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

  $customer_id = $::obmondo['customer_id']
  # lint:ignore:top_scope_facts
  $scrape_port = Integer($listen_address.split(':')[1])
  $scrape_host = $trusted['certname']

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
    extra_options                  => "--web.listen-address=${listen_address} --enable-feature=agent --storage.agent.path=/opt/obmondo/prometheus",
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
          source_labels => ['certname'],
          regex         => "(.*).${customer_id}",
          action        => 'keep',
        },
      ],
    }],
  }

  Monitor::Threshold <<| tag == $::trusted['certname'] |>>
  Monitor::Alert <<| tag == $::trusted['certname'] |>>
}
