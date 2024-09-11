# pressure stall information
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
