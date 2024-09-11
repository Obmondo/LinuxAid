# hwmon Checks
class monitor::system::hwmon (
  Boolean $enable = true,
) {

  if $facts['dmi']['board']['product'] == 'PRIME X670-P WIFI' {

    file {'/etc/modules-load.d/modules.conf':
      ensure  => 'present',
      content => 'options nct6775 force_id=0xd420'
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