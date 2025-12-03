# Systemd Journald Upload
class profile::logging::journal (
  Boolean               $enable       = $common::logging::journal::upload_enable,
  String                $package_name = $common::logging::journal::package_name,
  Eit_types::URL        $remote_url   = $common::logging::journal::remote_url,
  Eit_types::Noop_Value $noop_value   = $common::logging::journal::noop_value,
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
    [Unit]
    # Disable start-limit so the service doesn't give up after rapid failures
    StartLimitIntervalSec=5min
    StartLimitBurst=50

    [Service]
    # Disable watchdog
    WatchdogSec=0

    # Keep retrying if it fails
    Restart=always

    # Restart every 30s not every 100ms
    RestartSec=30s

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
