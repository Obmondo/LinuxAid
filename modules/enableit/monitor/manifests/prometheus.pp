# Prometheus
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
