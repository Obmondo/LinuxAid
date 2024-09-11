# Disk use check
class monitor::system::disk::usage (
  Boolean               $enable   = true,
  Eit_types::Percentage $space    = 80,
  Monitor::Disable      $disable  = undef,
  Hash                  $labels   = {},
  Monitor::Override     $override = undef,
) {

  @@monitor::alert { $title:
    enable  => $enable,
    disable => $disable,
    tag     => $::trusted['certname'],
  }

  @@monitor::threshold { $title:
    enable   => $enable,
    expr     => $space,
    labels   => $labels,
    override => $override,
    tag      => $::trusted['certname'],
  }
}
