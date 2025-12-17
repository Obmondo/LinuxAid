#
# Manages Wildfly service.
#
class wildfly::service {
  $config = wildfly::service_config($wildfly::distribution, $wildfly::version, $wildfly::mode)

  debug("${wildfly::distribution}.${wildfly::version}.${wildfly::mode}: ${config}")

  $conf_file = pick($wildfly::conf_file, $config['conf_file'])
  $conf_template = pick($wildfly::conf_template, $config['conf_template'])
  $service_name = pick($wildfly::service_name, $config['service_name'])
  $service_manage   = pick($wildfly::service_manage, $config['service_manage'])
  $service_file = pick($wildfly::service_file, $config['service_file'])
  $systemd_template = pick($wildfly::systemd_template, $config['systemd_template'], 'wildfly/wildfly.sysvinit.service')

  if !$wildfly::package_name {
    contain wildfly::service::systemd
  }

  $conf_dir = dirname($conf_file)

  if $conf_dir != '/etc/default' {
    file { $conf_dir:
      ensure => directory,
      before => File[$conf_file],
    }
  }

  if $service_manage {
    file { $conf_file:
      ensure  => file,
      content => epp($conf_template),
      notify  => Service['wildfly'],
    }
  } else {
    file { $conf_file:
      ensure  => file,
      content => epp($conf_template),
    }
  }

  service { 'wildfly':
    ensure     => $wildfly::service_ensure,
    name       => $service_name,
    enable     => $wildfly::service_enable,
    hasrestart => true,
    hasstatus  => true,
  }
}
