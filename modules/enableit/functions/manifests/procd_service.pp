# procd (OpenWrt) init script for a daemon.
# The caller declares Service[$name].
define functions::procd_service (
  String[1]             $command,
  String[1]             $user,
  Eit_types::Noop_Value $noop_value = undef,
) {

  $_start = 95
  $_init_script = "/etc/init.d/${name}"

  file { $_init_script:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => epp('functions/procd_service.sh.epp', {
      service => $name,
      command => $command,
      user    => $user,
      start   => $_start,
    }),
    noop    => $noop_value,
    notify  => Service[$name],
  }

  # The init service provider cannot enable a service at boot
  exec { "${_init_script} enable":
    path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin'],
    creates => "/etc/rc.d/S${_start}${name}",
    noop    => $noop_value,
    require => File[$_init_script],
    before  => Service[$name],
  }
}
