# hwmon Checks
class monitor::system::hwmon (
  Boolean $enable = true,
) {

  if $facts['dmi']['board']['product'] == 'PRIME X670-P WIFI' {

    file {'/etc/modprobe.d/nct6775.conf':
      ensure  => 'present',
      content => 'options nct6775 force_id=0xd420'
    }

    file {'/etc/modules-load.d/nct6775.conf':
      ensure  => 'present',
      content => 'nct6775'
    }
  }

  @@monitor::alert { "${title}::hightemp":
    enable => $enable,
    tag    => $::trusted['certname'],
  }

  @@monitor::alert { "${title}::highfanspeed":
    enable => $enable,
    tag    => $::trusted['certname'],
  }
}