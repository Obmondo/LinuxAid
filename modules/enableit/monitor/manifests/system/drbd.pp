# DRBD Checks
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
