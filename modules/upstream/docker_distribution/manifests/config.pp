class docker_distribution::config {
  file { $::docker_distribution::config_file:
    ensure  => 'file',
    owner   => root,
    group   => root,
    mode    => '0640',
    content => template("${module_name}/config.yml.erb"),
  }

  if $::docker_distribution::manage_as == 'service' and
  $::docker_distribution::journald_forward_enable and
  $::operatingsystemmajrelease == '7' {
    file { '/etc/systemd/system/docker-distribution.service.d':
      ensure => 'directory',
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    } ->
    file { '/etc/systemd/system/docker-distribution.service.d/journald.conf':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template("${module_name}/journald.conf.erb"),
    } ~>
    exec { 'systemctl-daemon-reload docker_distribution':
      refreshonly => true,
      command     => '/usr/bin/systemctl daemon-reload',
    }
  }
}
