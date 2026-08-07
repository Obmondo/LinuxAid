# @summary Class for managing the common::monitor::exporter::node Puppet class
#
# @param systemd Boolean indicating whether to enable the 'systemd' collector. Defaults to false.
#
# @param textfile_directory Absolute path for the textfile directory. Defaults to undef.
#
# @param listen_address The IP and port to listen on, as an Eit_types::IPPort. Defaults to undef.
#
# @param enable Boolean indicating whether the exporter is enabled. Defaults to true.
#
# @param noop_value Boolean value for noop mode. Defaults to false.
#
# @groups settings enable, noop_value
#
# @groups network listen_address
#
# @groups collectors systemd
#
# @groups directories textfile_directory
#
class common::monitor::exporter::node (
  Boolean $systemd,

  Stdlib::AbsolutePath $textfile_directory,
  Eit_types::IPPort    $listen_address,

  Boolean               $enable     = true,
  Eit_types::Noop_Value $noop_value = $common::monitor::exporter::noop_value,
) {
  unless $enable { return() }

  $version = '1.10.2'
  $lib_directory = '/var/lib/node_exporter'

  $_checksum = lookup('common::monitor::exporter::node::checksums')
  $install_method = lookup('common::monitor::prometheus::install_method')

  File {
    noop => $noop_value,
  }

  # NOTE: The underlying packages only works with systemd
  if $facts['service_provider'] == 'systemd' {
    include common::monitor::exporter::node::smartmon
    include common::monitor::exporter::node::topprocesses
    include common::monitor::exporter::node::lsof
    include common::monitor::exporter::node::ssacli
  }

  file { $lib_directory:
    ensure => 'directory',
  }

  file { $textfile_directory:
    ensure  => 'directory',
    owner   => 'node_exporter',
    # Let other application also write to this location
    purge   => false,
    recurse => false,
    group   => 'obmondo',
    mode    => '0775',
    require => [
      File[$lib_directory],
      Group['obmondo'],
    ]
  }

  $_init_style = $enable ? {
    true    => lookup('common::monitor::prometheus::init_style'),
    default => 'none',
  }

  $_package_name = $install_method ? {
    'package' => 'obmondo-node-exporter',
    default   => 'node_exporter'
  }

  $default_collectors = [
    'mountstats',
    if $systemd { 'systemd' },
  ].delete_undef_values

  class { 'prometheus::node_exporter':
    package_name      => $_package_name,
    version           => $version,
    install_method    => $install_method,
    init_style        => $_init_style,
    service_enable    => $enable,
    service_ensure    => ensure_service($enable),
    package_ensure    => $version,
    user              => 'node_exporter',
    group             => 'node_exporter',
    export_scrape_job => ! $enable,
    extra_options     => "--collector.textfile.directory=${textfile_directory} --web.listen-address=${listen_address}",
    scrape_host       => $::trusted['certname'],
    collectors_enable => $default_collectors,
    tag               => $::trusted['certname'],
    scrape_job_labels => {
      'certname' => $::trusted['certname']
    },
  }

  $port = Integer($listen_address.split(':')[1])

  @@prometheus::scrape_job { 'node':
    job_name    => 'node',
    tag         => $::trusted['certname'],
    targets     => [ "${trusted['certname']}:${port}" ],
    labels      => { 'certname' => $::trusted['certname'] },
    collect_dir => '/etc/prometheus/file_sd_config.d',
  }

  # NOTE: This is a daemon-reload, which will do a daemon-reload in noop mode.
  # upstream module cant handle noop. (which is correct)
  Exec <| tag == 'systemd-node_exporter.service-systemctl-daemon-reload' |> {
    noop        => $noop_value,
    subscribe   => File['/etc/systemd/system/node_exporter.service'],
  } ~> Service['node_exporter']

  Archive <| tag == "/tmp/node_exporter-${version}.tar.gz" |> {
    checksum        => $_checksum[$version],
    checksum_verify => true,
    noop            => $noop_value,
  }

  firewall { '100 allow node exporter':
    ensure   => ensure_present($enable and $listen_address !~ /^127\./),
    proto    => 'tcp',
    protocol => 'iptables',
    dport    => $listen_address.split(':')[1],
    jump     => 'accept',
  }
}
