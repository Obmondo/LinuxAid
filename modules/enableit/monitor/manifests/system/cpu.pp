# CPU use
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
