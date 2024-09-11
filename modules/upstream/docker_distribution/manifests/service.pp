class docker_distribution::service {
  if $::docker_distribution::manage_as == 'service' {
    service { $docker_distribution::service_name:
      ensure => $::docker_distribution::service_ensure,
      enable => $::docker_distribution::service_enable,
    }
  } else {
    service { $docker_distribution::service_name:
      ensure => 'stopped',
      enable => false,
    }
  }
}
