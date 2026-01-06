# @summary Class for monitoring system services that are down
#
# @param enable Boolean to enable or disable the monitor. Defaults to true.
#
# @param blacklist Array of service names to blacklist. Defaults to an empty array.
#
# @param disable Optional Monitor::Disable to disable the monitor.
#
# @param override Optional Monitor::Override for overriding threshold conditions.
#
# @groups activation enable, disable.
#
# @groups configuration blacklist, override.
#
class monitor::system::service::down (
  Boolean       $enable    = true,
  Array[String] $blacklist = [],

  Monitor::Disable  $disable  = undef,
  Monitor::Override $override = undef,
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
}
