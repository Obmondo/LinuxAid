# Manages Wildfly service.
class wildfly::service {

  $config = service_config($wildfly::distribution, $wildfly::version, $wildfly::mode, $wildfly::init_system)

  debug("${wildfly::distribution}.${wildfly::version}.${wildfly::mode}.${wildfly::init_system}: ${config}")

  $conf_file = pick($wildfly::conf_file, $config['conf_file'])
  $conf_template = pick($wildfly::conf_template, $config['conf_template'])
  $service_name = pick($wildfly::service_name, $config['service_name'])
  $service_file = pick($wildfly::service_file, $config['service_file'])

  $systemd_template = $config['systemd_template']
  $systemd_native = $config['systemd_native']

  if !$wildfly::package_name {
    contain "wildfly::service::${wildfly::init_system}"
  }

  $conf_dir = dirname($conf_file)

  if $conf_dir != '/etc/default' {

    file { $conf_dir:
      ensure => directory,
      before => File[$conf_file],
    }

  }

  file { $conf_file:
    ensure  => present,
    content => epp($conf_template),
  }
  ~>
  service { 'wildfly':
    ensure     => $wildfly::service_ensure,
    name       => $service_name,
    enable     => $wildfly::service_enable,
    hasrestart => true,
    hasstatus  => true,
  }

}
