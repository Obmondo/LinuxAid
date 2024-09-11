# NTP thresholds
class monitor::system::ntp (
  Boolean            $enable = true,
  Integer[0,default] $offset = 3000,
) {

  @@monitor::alert { "${title}::sync":
    enable => $enable,
    tag    => $::trusted['certname'],
  }

  @@monitor::alert { "${title}::skew":
    enable => $enable,
    tag    => $::trusted['certname'],
  }

  @@monitor::threshold { "${title}::skew":
    enable => $enable,
    expr   => $offset,
    tag    => $::trusted['certname'],
  }
}
