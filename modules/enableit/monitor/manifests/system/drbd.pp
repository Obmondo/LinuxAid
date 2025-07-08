# @summary Class for managing DRBD checks
#
# @param enable Boolean to enable or disable the DRBD checks. Defaults to true.
#
class monitor::system::drbd (
  Boolean $enable = true,
) {
  @@monitor::alert { "${title}::uptodate":
    enable => $enable,
    tag    => $::trusted['certname'],
  }
  @@monitor::alert { "${title}::connected":
    enable => $enable,
    tag    => $::trusted['certname'],
  }
}
