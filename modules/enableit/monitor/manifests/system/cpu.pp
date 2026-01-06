# @summary Class for monitoring system CPU usage
#
# @param enable Boolean indicating if monitoring is enabled. Defaults to true.
#
# @param enable_temp Boolean indicating if temperature monitoring is enabled. Defaults to false.
#
# @param usage Percentage value for CPU usage threshold. Defaults to 80.
#
# @param temperature Percentage value for CPU temperature threshold. Defaults to 80.
#
# @param disable Optional disable parameter for CPU usage monitor.
#
# @param disable_temp Optional disable parameter for temperature monitor.
#
# @param override Optional override parameter for CPU usage threshold.
#
# @param override_temp Optional override parameter for temperature threshold.
#
# @groups enable disable, enable, override, usage
#
# @groups temperature enable_temp, temperature, disable_temp, override_temp
#
class monitor::system::cpu (
  Boolean               $enable        = true,
  Boolean               $enable_temp   = false,
  Eit_types::Percentage $usage         = 80,
  Eit_types::Percentage $temperature   = 80,
  Monitor::Disable      $disable       = undef,
  Monitor::Disable      $disable_temp  = undef,
  Monitor::Override     $override      = undef,
  Monitor::Override     $override_temp = undef,
) {

  @@monitor::alert { "${name}::usage":
    enable  => $enable,
    disable => $disable,
    tag     => $::trusted['certname'],
  }

  @@monitor::threshold { "${name}::usage":
    enable   => $enable,
    expr     => $usage,
    tag      => $::trusted['certname'],
    override => $override,
  }

  @@monitor::alert { "${name}::temperature":
    enable  => $enable_temp,
    disable => $disable_temp,
    tag     => $::trusted['certname'],
  }

  @@monitor::threshold { "${name}::temperature":
    enable   => $enable_temp,
    expr     => $temperature,
    tag      => $::trusted['certname'],
    override => $override_temp,
  }
}
