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
# @param noop_value Notifies Puppet to define if changes are to be made to the system or simulated.
#
# @groups configuration version, config_dir, enable, noop_value.
#
# @groups network collect_scrape_jobs, listen_address.
#
class common::monitor::prometheus::server (
  Eit_types::Version    $version,
  Array[Hash]           $collect_scrape_jobs,
  Stdlib::Absolutepath  $config_dir,
  Eit_types::IPPort     $listen_address,

  Boolean               $enable     = $common::monitor::enable,
  Eit_types::Noop_Value $noop_value = $common::monitor::noop_value,
) {

  Exec {
    noop => $noop_value,
  }

  File {
    noop => $noop_value,
  }

  file { '/opt/obmondo/prometheus':
    ensure  => directory,
    owner   => 'prometheus',
    group   => 'prometheus',
    require => User['prometheus'],
    notify  => Service['prometheus'],
  }

  $scrape_port = Integer($listen_address.split(':')[1])
  $scrape_host = $trusted['certname']
  $_extra_options = "--web.listen-address=${listen_address} --agent --storage.agent.path=/opt/obmondo/prometheus"
  $_prometheus_url = "https://${common::monitor::prometheus::server}/api/v1/write"
  $install_method = lookup('common::monitor::prometheus::install_method')

  $_shared_dir = $install_method ? {
    'package' => '/usr/local/share/prometheus',
    default => '/usr/share/prometheus',
  }

  $_package_name = $install_method ? {
    'package' => 'obmondo-prometheus',
    default   => 'prometheus',
  }

  class { 'prometheus::server':
    version                        => $version,
    package_ensure                 => $version,
    storage_retention              => false,
    localstorage                   => false,
    collect_scrape_jobs            => $collect_scrape_jobs,
    collect_tag                    => $::trusted['certname'],
    extra_groups                   => ['obmondo'],
    global_config                  => {
      scrape_interval => '15s',
      evaluation_interval => '15s',
      external_labels => {
        product => 'linuxaid',
      },
    },
    install_method                 => $install_method,
    shared_dir                     => $_shared_dir,
    include_default_scrape_configs => false,
    config_dir                     => $config_dir,
    manage_config_dir              => true,
    restart_on_change              => true,
    package_name                   => $_package_name,
    bin_dir                        => '/opt/obmondo/bin',
    extra_options                  => $_extra_options,
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
      url                   => $_prometheus_url,
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
          regex         => $trusted['certname'],
          action        => 'keep',
        },
      ],
    }],
  }

  Monitor::Threshold <<| tag == $::trusted['certname'] |>>
  Monitor::Alert <<| tag == $::trusted['certname'] |>>

  $_checksum = lookup('common::monitor::exporter::node::checksums')

  Archive <| tag == "/tmp/prometheus-${version}.tar.gz" |> {
    checksum        => $_checksum[$version],
    checksum_verify => true,
    noop            => $noop_value,
  }

}
