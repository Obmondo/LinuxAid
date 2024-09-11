define drbd::migration (
  $ha_primary,
  $service,
  $volume
) {

  Exec {
    path => ['/sbin', '/bin', '/usr/sbin', '/usr/bin'],
  }

  exec { "stop ${service} for drbd migration":
    command => "service ${service} stop",
    # this should probably be more precise. If we're not linked into the
    # drbd volume we still would need to migrate
    unless  => "test -L ${name}",
    require => Drbd::Resource[$volume],
  }

  if $ha_primary {
    exec { "migrate ${service} to drbd":
      command     => "mv ${name} /drbd/${volume}/${service}",
      subscribe   => Exec["stop ${service} for drbd migration"],
      before      => File[$name],
      refreshonly => true,
    }

    exec { "start ${service} after drbd migration":
      command     => "service ${service} start",
      refreshonly => true,
      subscribe   => File[$name],
    }

  } else {
    exec { "remove ${service} data on secondary node":
      command     => "rm -r ${name}",
      subscribe   => Exec["stop ${service} for drbd migration"],
      before      => File[$name],
      refreshonly => true,
    }
  }

  file { $name:
    ensure => link,
    target => "/drbd/${volume}/${service}",
  }
}
