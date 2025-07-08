# @summary Class for managing system load monitoring
#
# @param enable Boolean indicating whether monitoring is enabled. Defaults to true.
#
# @param load1_percpu Threshold for 1-minute load per CPU. Defaults to 600.
#
# @param load5_percpu Threshold for 5-minute load per CPU. Defaults to 400.
#
# @param load15_percpu Threshold for 15-minute load per CPU. Defaults to 300.
#
# @param disable Optional parameter to disable the monitor. Defaults to undef.
#
# @param override_load1 Optional override for load1_percpu threshold. Defaults to undef.
#
# @param override_load5 Optional override for load5_percpu threshold. Defaults to undef.
#
class monitor::system::load (
  Boolean              $enable          = true,
  Eit_types::Threshold $load1_percpu    = 600,
  Eit_types::Threshold $load5_percpu    = 400,
  Eit_types::Threshold $load15_percpu   = 300,
  Monitor::Disable     $disable         = undef,
  Monitor::Override    $override_load1  = undef,
  Monitor::Override    $override_load5  = undef,
  Monitor::Override    $override_load15 = undef,
) {

  @@monitor::alert { "${title}::load_percpu":
    enable  => $enable,
    disable => $disable,
    tag     => $::trusted['certname'],
  }

  @@monitor::threshold { "${title}::load1_percpu":
    enable   => $enable,
    expr     => $load1_percpu,
    override => $override_load1,
    tag      => $::trusted['certname'],
  }

  @@monitor::threshold { "${title}::load5_percpu":
    enable   => $enable,
    expr     => $load5_percpu,
    override => $override_load5,
    tag      => $::trusted['certname'],
  }

  @@monitor::threshold { "${title}::load15_percpu":
    enable   => $enable,
    expr     => $load15_percpu,
    override => $override_load15,
    tag      => $::trusted['certname'],
  }
}
