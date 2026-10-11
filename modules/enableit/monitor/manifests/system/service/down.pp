# @summary Class for monitoring system services that are down
#
# @param enable Boolean to enable or disable the monitor. Defaults to true.
#
# @param blacklist Array of service names to blacklist. Defaults to an empty array.
#
# @param blacklist_glob Array of systemctl unit globs, e.g. `'vsts.agent.*'`,
#   for units with dynamic names. A systemd timer expands them into blacklist
#   entries on the node every 5 minutes. Defaults to an empty array.
#
# @param noop_value The noop value for the glob expansion resources. Defaults to $monitor::noop_value.
#
# @param disable Optional Monitor::Disable to disable the monitor.
#
# @param override Optional Monitor::Override for overriding threshold conditions.
#
# @groups activation enable, disable.
#
# @groups configuration blacklist, blacklist_glob, override, noop_value.
#
class monitor::system::service::down (
  Boolean       $enable         = true,
  Array[String] $blacklist      = [],
  Array[String] $blacklist_glob = [],

  Monitor::Disable      $disable    = undef,
  Monitor::Override     $override   = undef,
  Eit_types::Noop_Value $noop_value = $monitor::noop_value,
) {
  @@monitor::alert { $name:
    enable  => $enable,
    disable => $disable,
    tag     => $::trusted['certname'],
  }
  $blacklist.each |$_service| {
    $_service_name = if $_service.match(/\.service$/) {
      $_service
    } else {
      "${_service}.service"
    }
    @@monitor::threshold { "${name}::blacklist::${_service_name}":
      record   => "${name}::blacklist",
      expr     => 1,
      override => $override,
      tag      => $::trusted['certname'],
      labels   => {
        'name' => $_service_name,
      }
    }
  }

  $_glob_enable = $enable and !$blacklist_glob.empty
  $_textfile_dir = lookup('common::monitor::exporter::node::textfile_directory', Stdlib::AbsolutePath)
  $_glob_script = '/opt/obmondo/bin/service-down-blacklist-glob'
  $_glob_config = '/etc/default/obmondo-service-down-blacklist-glob'
  $_glob_exclude = $blacklist.map |$_service| {
    if $_service =~ /\.service$/ { $_service } else { "${_service}.service" }
  }

  file { $_glob_script:
    ensure => ensure_file($_glob_enable),
    source => 'puppet:///modules/monitor/service-down-blacklist-glob.sh',
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
    noop   => $noop_value,
  }

  file { $_glob_config:
    ensure  => ensure_file($_glob_enable),
    content => @("EOT"),
      # THIS FILE IS MANAGED BY OBMONDO. CHANGES WILL BE LOST.
      TARGET_FILE=${shell_escape("${_textfile_dir}/threshold_monitor_system_service_down_blacklist_glob.prom")}
      CERTNAME=${shell_escape($::trusted['certname'])}
      GLOBS=(${blacklist_glob.map |$_g| { shell_escape($_g) }.join(' ')})
      EXCLUDE=(${_glob_exclude.map |$_e| { shell_escape($_e) }.join(' ')})
      | EOT
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    noop    => $noop_value,
  }

  systemd::timer { 'obmondo-service-down-blacklist-glob.timer':
    ensure          => ensure_present($_glob_enable),
    timer_content   => @(EOT),
      [Unit]
      Description=Expand monitor::system::service::down blacklist globs
      [Timer]
      OnBootSec=1m
      OnUnitActiveSec=5m
      [Install]
      WantedBy=timers.target
      | EOT
    service_content => @("EOT"),
      [Unit]
      Description=Expand monitor::system::service::down blacklist globs
      [Service]
      Type=oneshot
      ExecStart=${_glob_script}
      | EOT
    active          => $_glob_enable,
    enable          => $_glob_enable,
    noop            => $noop_value,
    require         => if $_glob_enable { [File[$_glob_script], File[$_glob_config]] },
  }

  unless $_glob_enable {
    file { "${_textfile_dir}/threshold_monitor_system_service_down_blacklist_glob.prom":
      ensure => absent,
      noop   => $noop_value,
    }
  }
}
