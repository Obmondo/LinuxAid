# exec_once
define profile::system::service_oneshot (
  String  $content,
) {

$file_path = "/opt/obmondo/bin/${name}"

  file { "${file_path}":
    ensure  => 'file',
    content => base64('decode', $file_content),
    mode    => '0700',
    owner   => 'root',
    group   => 'root',
    noop    => false,
  }

  common::services::systemd { "${name}.service":
    enable     => false,
    ensure     => 'running',
    unit       => {
      'Description'    => "${name} Once Service",
    },
    service    => {
      'Type'            => 'oneshot',
      'ExecStart'       => "/bin/sh -c ${file_path}",
      'RemainAfterExit' => 'Yes',
    },
    install    => {
      'WantedBy'        => 'multi-user.target'
    },
    require    => File["${file_path}"],
    noop_value => false,
  }
}
