# @summary Class for managing the common::monitor::exporter::node Puppet class
#
# @param buddyinfo Boolean indicating whether to enable the 'buddyinfo' collector. Defaults to false.
#
# @param cgroups Boolean indicating whether to enable the 'cgroups' collector. Defaults to false.
#
# @param drbd Boolean indicating whether to enable the 'drbd' collector. Defaults to false.
#
# @param drm Boolean indicating whether to enable the 'drm' collector. Defaults to false.
#
# @param ethtool Boolean indicating whether to enable the 'ethtool' collector. Defaults to false.
#
# @param interrupts Boolean indicating whether to enable the 'interrupts' collector. Defaults to false.
#
# @param ksmd Boolean indicating whether to enable the 'ksmd' collector. Defaults to false.
#
# @param lnstat Boolean indicating whether to enable the 'lnstat' collector. Defaults to false.
#
# @param logind Boolean indicating whether to enable the 'logind' collector. Defaults to false.
#
# @param meminfo_numa Boolean indicating whether to enable the 'meminfo_numa' collector. Defaults to false.
#
# @param mountstats Boolean indicating whether to enable the 'mountstats' collector. Defaults to false.
#
# @param network_route Boolean indicating whether to enable the 'network_route' collector. Defaults to false.
#
# @param ntp Boolean indicating whether to enable the 'ntp' collector. Defaults to false.
#
# @param perf Boolean indicating whether to enable the 'perf' collector. Defaults to false.
#
# @param processes Boolean indicating whether to enable the 'processes' collector. Defaults to false.
#
# @param qdisc Boolean indicating whether to enable the 'qdisc' collector. Defaults to false.
#
# @param runit Boolean indicating whether to enable the 'runit' collector. Defaults to false.
#
# @param slabinfo Boolean indicating whether to enable the 'slabinfo' collector. Defaults to false.
#
# @param supervisord Boolean indicating whether to enable the 'supervisord' collector. Defaults to false.
#
# @param sysctl Boolean indicating whether to enable the 'sysctl' collector. Defaults to false.
#
# @param systemd Boolean indicating whether to enable the 'systemd' collector. Defaults to false.
#
# @param tcpstat Boolean indicating whether to enable the 'tcpstat' collector. Defaults to false.
#
# @param thermal_zone Boolean indicating whether to enable the 'thermal_zone' collector. Defaults to false.
#
# @param wifi Boolean indicating whether to enable the 'wifi' collector. Defaults to false.
#
# @param zoneinfo Boolean indicating whether to enable the 'zoneinfo' collector. Defaults to false.
#
# @param textfile_directory Absolute path for the textfile directory. Defaults to undef.
#
# @param lib_directory Absolute path for the library directory. Defaults to undef.
#
# @param listen_address The IP and port to listen on, as an Eit_types::IPPort. Defaults to undef.
#
# @param enable Boolean indicating whether the exporter is enabled. Defaults to true.
#
# @param noop_value Boolean value for noop mode. Defaults to false.
#
class common::monitor::exporter::node (
  Boolean      $buddyinfo,
  Boolean      $cgroups,
  Boolean      $drbd,
  Boolean      $drm,
  Boolean      $ethtool,
  Boolean      $interrupts,
  Boolean      $ksmd,
  Boolean      $lnstat,
  Boolean      $logind,
  Boolean      $meminfo_numa,
  Boolean      $mountstats,
  Boolean      $network_route,
  Boolean      $ntp,
  Boolean      $perf,
  Boolean      $processes,
  Boolean      $qdisc,
  Boolean      $runit,
  Boolean      $slabinfo,
  Boolean      $supervisord,
  Boolean      $sysctl,
  Boolean      $systemd,
  Boolean      $tcpstat,
  Boolean      $thermal_zone,
  Boolean      $wifi,
  Boolean      $zoneinfo,

  Stdlib::AbsolutePath $textfile_directory,
  Stdlib::AbsolutePath $lib_directory,
  Eit_types::IPPort    $listen_address,

  Eit_types::Certname   $host       = $trusted['certname'],
  Boolean               $enable     = true,
  Eit_types::Version    $version    = '1.10.2',
  Eit_types::Noop_Value $noop_value = $common::monitor::exporter::noop_value,
) {
  confine($perf, 'perf needs a profiler to work. remove this confine when fixed')

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

  $default_collectors = [
    if $buddyinfo { 'buddyinfo' },
    if $cgroups { 'cgroups' },
    if $drbd and $facts['drbdpeerstate1'] { 'drbd' },
    if $drm { 'drm' },
    if $ethtool { 'ethtool' },
    if $interrupts { 'interrupts' },
    if $ksmd { 'ksmd' },
    if $lnstat { 'lnstat' },
    if $logind { 'logind' },
    if $meminfo_numa { 'meminfo_numa' },
    if $mountstats { 'mountstats' },
    if $network_route { 'network_route' },
    if $ntp { 'ntp' },
    if $perf { 'perf' },
    if $processes { 'processes' },
    if $qdisc { 'qdisc' },
    if $runit { 'runit' },
    if $slabinfo { 'slabinfo' },
    if $supervisord { 'supervisord' },
    if $sysctl { 'sysctl' },
    if $systemd { 'systemd' },
    if $tcpstat { 'tcpstat' },
    if $thermal_zone { 'thermal_zone' },
    if $wifi { 'wifi' },
    if $zoneinfo { 'zoneinfo' },
  ].delete_undef_values

  class { 'prometheus::node_exporter':
    package_name      => 'obmondo-node-exporter',
    version           => $version,
    install_method    => $install_method,
    init_style        => $_init_style,
    service_enable    => $enable,
    service_ensure    => ensure_service($enable),
    package_ensure    => ensure_latest($enable),
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
    targets     => [ "${host}:${port}" ],
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
