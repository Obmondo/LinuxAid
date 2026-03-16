# service_oneshot is a service, which runs only once
# and remainsexited
define profile::system::service_oneshot (
  Stdlib::Base64        $content,
  Boolean               $enable     = true,
  Eit_types::Noop_Value $noop_value = undef,
) {

  $file_path = "/opt/obmondo/bin/${name}"

  file { $file_path:
    ensure  => ensure_file($enable),
    content => base64('decode', $content),
    mode    => '0700',
    owner   => 'root',
    group   => 'root',
    noop    => $noop_value,
  }

  # Define the dynamic service content
  $_service_content = @("EOT"/)
    # THIS FILE IS MANAGED BY OBMONDO. CHANGES WILL BE LOST.
    [Unit]
    Description=${name} Service

    [Service]
    Type=oneshot
    ExecStart=${file_path}
    RemainAfterExit=Yes

    [Install]
    WantedBy=multi-user.target
    | EOT

  # Manage the unit file on disk
  systemd::unit_file { "${name}.service":
    ensure  => present,
    content => $_service_content,
    noop    => $noop_value,
    require => File[$file_path],
  }

  # Manage the service state
  # Note: enable is false per original code, state managed by ensure_service
  service { "${name}.service":
    ensure    => ensure_service($enable),
    enable    => false,
    noop      => $noop_value,
    subscribe => Systemd::Unit_file["${name}.service"],
  }
}
