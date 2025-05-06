# Systemd Journald Upload
class profile::logging::journal (
  Boolean           $enable       = $common::logging::journal::upload_enable,
  String            $package_name = $common::logging::journal::package_name,
  Eit_types::URL    $remote_url   = $common::logging::journal::remote_url,
  Optional[Boolean] $noop_value   = $common::logging::journal::noop_value,
) {

  File {
    noop => $noop_value,
  }

  Package {
    noop => $noop_value,
  }

  Service {
    noop => $noop_value,
  }

  Ini_setting {
    noop => $noop_value,
  }

  user { 'systemd-journal-upload':
    ensure => ensure_present($enable),
    noop   => $noop_value,
  }

  confine($facts['init_system'] != 'systemd', 'Only systemd is supported')

  $_service = @(EOT)
    [Service]
    # https://www.freedesktop.org/software/systemd/man/latest/systemd.service.html#WatchdogSec=
    WatchdogSec=0
    Restart=always
    | EOT

  systemd::dropin_file { 'upload-remote_dropin':
    filename => 'upload-service-override.conf',
    unit     => 'systemd-journal-upload.service',
    content  => $_service,
    notify   => Service['systemd-journal-upload'],
  }

  class { '::systemd_journal_remote':
    package_name   => $package_name,
    manage_package => if $enable { true },
    package_ensure => ensure_present($enable),
  }

  class { '::systemd_journal_remote::upload':
    manage_service => $enable,
    service_ensure => ensure_service($enable),
    command_flags  => {
      'save-state' => '/var/lib/systemd/journal-upload/state',
    },
    options        => if $enable {{
      'URL' => "${remote_url}:19532",
    }}
  }
}
