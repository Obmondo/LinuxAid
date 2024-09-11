# Swap
class monitor::system::swap (
  Boolean               $enable  = true,
  Eit_types::Percentage $warning = 80,
) {

  @@monitor::alert { "${title}::used":
    enable => $enable,
    tag    => $::trusted['certname'],
  }

  @@monitor::threshold { "${title}::used":
    enable => $enable,
    expr   => $warning,
    tag    => $::trusted['certname'],
  }
}
