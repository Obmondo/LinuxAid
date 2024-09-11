# Load
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
