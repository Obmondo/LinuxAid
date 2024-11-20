# Prometheus node-exporter
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

  Eit_types::IPPort $listen_address,
  Boolean[true]     $enable,
  Boolean[false]    $noop_value,
) {
  confine($perf, 'perf needs a profiler to work. remove this confine when fixed')

  File {
    noop => $noop_value,
  }

  include common::monitor::prom
  include common::monitor::exporter::node::smartmon
  include common::monitor::exporter::node::topprocesses
  include common::monitor::exporter::node::lsof
  include common::monitor::exporter::node::ssacli

  file { $lib_directory:
    ensure =>  'directory',
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
    service_enable    => $enable,
    service_ensure    => ensure_service($enable),
    package_ensure    => ensure_latest($enable),
    init_style        => if !$enable { 'none' },
    user              => 'node_exporter',
    group             => 'node_exporter',
    export_scrape_job => $enable,
    extra_options     => "--web.listen-address=${listen_address} --collector.textfile.directory=${textfile_directory}",
    scrape_port       => Integer($listen_address.split(':')[1]),
    scrape_host       => $::trusted['certname'],
    collectors_enable => $default_collectors,
    tag               => $::trusted['certname'],
    scrape_job_labels => { 'certname' => $::trusted['certname'] },
  }

  # NOTE: This is a daemon-reload, which will do a daemon-reload in noop mode.
  # upstream module cant handle noop. (which is correct)
  Exec <| tag == 'systemd-node_exporter.service-systemctl-daemon-reload' |> {
    noop => $noop_value,
  }

  firewall { '100 allow node exporter':
    ensure   => ensure_present($enable and $listen_address !~ /^127\./),
    proto    => 'tcp',
    protocol => 'iptables',
    dport    => $listen_address.split(':')[1],
    jump     => 'accept',
  }

}
