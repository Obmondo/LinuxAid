# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include thinlinc::service
class thinlinc::service (
  Array[String] $services,
) inherits ::thinlinc {

  if $facts['service_provider'] == 'systemd' {
    exec { 'systemd reload service units':
      command     => 'systemctl daemon-reload',
      path        => ['/bin', '/usr/bin'],
      refreshonly => true,
    }

    $services.each |$_service| {
      $_unit = "${_service}.service"
      # $_systemd_unit_d = "/etc/systemd/system/${_unit}.d"
      # file { $_systemd_unit_d:
      #   ensure  => 'directory',
      #   purge   => true,
      #   recurse => true,
      # }

      file { "/etc/systemd/system/${_unit}":
        ensure  => 'file',
        content => epp('thinlinc/etc/systemd.service.epp', {
          exec_start => "/opt/thinlinc/sbin/${_service}",
        }),
        before  => Service[$_service],
        notify  => [
          Exec['systemd reload service units'],
          Service[$_service],
        ],
      }
    }
  }

  service { $services:
    ensure => running,
    enable => true,
  }

  cron::job { 'tl-statistics-cron':
    minute      => '*/5',
    user        => 'root',
    command     => 'chronic tl-collect-licensestats',
    environment => [
      'PATH=/opt/thinlinc/sbin:/usr/local/bin:/usr/bin:/bin',
    ],
  }
}
