# @summary Class for managing system swap monitoring
#
# @param enable Whether to enable swap monitoring. Defaults to true.
#
# @param warning The percentage threshold for warning alert. Defaults to 80.
#
# @groups settings enable, warning.
#
class monitor::system::swap (
  Boolean $enable       = true,
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
