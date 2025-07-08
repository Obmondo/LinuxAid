# @summary Class for monitoring RAM usage
#
# @param enable Whether to enable the RAM monitoring. Defaults to true.
#
# @param warning The warning threshold as a percentage. Defaults to 80.
#
# @param critical The critical threshold as a percentage. Defaults to 95.
#
# @param disable_used Optional disable parameter for used memory alert.
#
# @param disable_used_high Optional disable parameter for high used memory alert.
#
# @param disable_oom Optional disable parameter for OOM alert.
#
# @param override_used Optional override parameter for used memory alert.
#
# @param override_used_high Optional override parameter for high used memory alert.
#
# @param override_oom Optional override parameter for OOM alert.
#
class monitor::system::ram (
  Boolean               $enable   = true,
  Eit_types::Percentage $warning  = 80,
  Eit_types::Percentage $critical = 95,

  Monitor::Disable      $disable_used      = undef,
  Monitor::Disable      $disable_used_high = undef,
  Monitor::Disable      $disable_oom       = undef,
  Monitor::Override     $override_used      = undef,
  Monitor::Override     $override_used_high = undef,
  Monitor::Override     $override_oom       = undef,
) {
  @@monitor::alert { "${title}::used":
    enable  => $enable,
    disable => $disable_used,
    tag     => $::trusted['certname'],
  }
  @@monitor::alert { "${title}::used_high":
    enable  => $enable,
    disable => $disable_used_high,
    tag     => $::trusted['certname'],
  }
  @@monitor::alert { "${title}::oom":
    enable  => $enable,
    disable => $disable_oom,
    tag     => $::trusted['certname'],
  }
  @@monitor::threshold { "${title}::used":
    enable   => $enable,
    expr     => $warning,
    override => $override_used,
    tag      => $::trusted['certname'],
  }
  @@monitor::threshold { "${title}::used_high":
    enable   => $enable,
    expr     => $critical,
    override => $override_used_high,
    tag      => $::trusted['certname'],
  }
  @@monitor::threshold { "${title}::oom":
    enable   => $enable,
    expr     => $critical,
    override => $override_oom,
    tag      => $::trusted['certname'],
  }
}
