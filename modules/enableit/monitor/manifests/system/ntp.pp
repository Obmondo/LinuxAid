# @summary Class for monitoring system NTP thresholds
#
# @param enable Boolean indicating whether NTP monitoring is enabled. Defaults to true.
#
# @param offset Integer representing the offset threshold for NTP skew in milliseconds. Defaults to 3000.
#
# @groups configuration enable, offset
#
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
