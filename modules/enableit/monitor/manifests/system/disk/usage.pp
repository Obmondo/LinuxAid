# @summary Class for monitoring disk usage
#
# @param enable Whether to enable the disk use check. Defaults to true.
#
# @param space The threshold percentage for disk space usage. Defaults to 80.
#
# @param disable Optional disable parameter for the monitor. Defaults to undef.
#
# @param labels Labels for the monitor. Defaults to an empty hash.
#
# @param override Override settings for the monitor. Defaults to undef.
#
# @param ignore_mountpoints Mountpoints to be ignored during monitoring. Defaults to an empty array.
#
# @groups monitor_settings enable, disable, override
#
# @groups disk_settings space, ignore_mountpoints
#
# @groups metadata labels
#
class monitor::system::disk::usage (
  Boolean               $enable   = true,
  Eit_types::Percentage $space    = 80,
  Monitor::Disable      $disable  = undef,
  Hash                  $labels   = {},
  Monitor::Override     $override = undef,
  Array[Stdlib::Unixpath] $ignore_mountpoints = [],
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

  $ignore_mountpoints.each |$_mountpoint| {
    @@monitor::threshold { "${title}::ignore_mountpoints":
      record   => "${title}::ignore_mountpoints",
      expr     => 1,
      override => $override,
      tag      => $::trusted['certname'],
      labels   => {
        'mountpoint' => $_mountpoint,
      }
    }
  }
}
