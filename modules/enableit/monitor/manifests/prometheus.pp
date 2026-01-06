# @summary Class for managing Prometheus monitoring
#
# @param enable Whether to enable the Prometheus monitoring. Defaults to true.
#
# @groups settings enable
#
class monitor::prometheus (
  Boolean $enable = true,
) {
  @@monitor::alert { "${name}::metrics":
    enable => $enable,
    tag    => $::trusted['certname'],
  }
  @@monitor::alert { "${name}::largescrape":
    enable => $enable,
    tag    => $::trusted['certname'],
  }
  @@monitor::alert { "${name}::walcorruptions":
    enable => $enable,
    tag    => $::trusted['certname'],
  }
  @@monitor::alert { "${name}::scrapingslow":
    enable => $enable,
    tag    => $::trusted['certname'],
  }
}
