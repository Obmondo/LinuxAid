# RAM use
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
