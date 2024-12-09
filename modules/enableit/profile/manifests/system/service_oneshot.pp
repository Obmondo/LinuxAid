# service_oneshot is a service, which runs only once
# and remainsexited
define profile::system::service_oneshot (
  Stdlib::Base64 $content,

  Boolean $enable     = true,
  Boolean $noop_value = false,
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

  common::services::systemd { "${name}.service":
    ensure     => ensure_service($enable),
    enable     => false,
    unit       => {
      'Description'    => "${name} Service",
    },
    service    => {
      'Type'            => 'oneshot',
      'ExecStart'       => $file_path,
      'RemainAfterExit' => 'Yes',
    },
    install    => {
      'WantedBy'        => 'multi-user.target'
    },
    require    => File[$file_path],
    noop_value => $noop_value,
  }
}
