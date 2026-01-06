# @summary Class for managing pressure stall information
#
# @param enable Whether to enable the PSI monitoring. Defaults to false.
#
# @param io I/O pressure threshold as a float. Defaults to 0.5.
#
# @param memory Memory pressure threshold as a float. Defaults to 0.04.
#
# @param cpu CPU pressure threshold as a float. Defaults to 0.6.
#
# @param disable_io Optional disable condition for I/O pressure monitoring.
#
# @param disable_memory Optional disable condition for memory pressure monitoring.
#
# @param disable_cpu Optional disable condition for CPU pressure monitoring.
#
# @param override_io Optional override setting for I/O pressure threshold.
#
# @param override_memory Optional override setting for memory pressure threshold.
#
# @param override_cpu Optional override setting for CPU pressure threshold.
#
# @groups enablement enable.
#
# @groups threshold io, memory, cpu.
#
# @groups disable_conditions disable_io, disable_memory, disable_cpu.
#
# @groups overrides override_io, override_memory, override_cpu.
#
class monitor::system::psi (
  Boolean $enable = false,
  Float   $io     = 0.5,
  Float   $memory = 0.04,
  Float   $cpu    = 0.6,
  Monitor::Disable $disable_io     = undef,
  Monitor::Disable $disable_memory = undef,
  Monitor::Disable $disable_cpu    = undef,
  Monitor::Override $override_io     = undef,
  Monitor::Override $override_memory = undef,
  Monitor::Override $override_cpu    = undef,
) {
  @@monitor::alert { "${title}::io":
    enable  => $enable,
    disable => $disable_io,
    tag     => $::trusted['certname'],
  }
  @@monitor::alert { "${title}::memory":
    enable  => $enable,
    disable => $disable_memory,
    tag     => $::trusted['certname'],
  }
  @@monitor::alert { "${title}::cpu":
    enable  => $enable,
    disable => $disable_cpu,
    tag     => $::trusted['certname'],
  }
  @@monitor::threshold { "${title}::io":
    enable   => $enable,
    expr     => $io,
    override => $override_io,
    tag      => $::trusted['certname'],
  }
  @@monitor::threshold { "${title}::memory":
    enable   => $enable,
    expr     => $memory,
    override => $override_memory,
    tag      => $::trusted['certname'],
  }
  @@monitor::threshold { "${title}::cpu":
    enable   => $enable,
    expr     => $cpu,
    override => $override_cpu,
    tag      => $::trusted['certname'],
  }
}
