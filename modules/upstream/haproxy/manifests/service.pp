# @summary
#   HAProxy service
# @api private
define haproxy::service (
  # lint:ignore:140chars
  String $instance_name,
  Variant[Enum['running', 'stopped'], Boolean]  $service_ensure,
  Boolean                                       $service_manage,
  Optional[String]                              $restart_command = undef,  # A default is required for Puppet 2.7 compatibility. When 2.7 is no longer supported, this parameter default should be removed. << Update 16/12/22 default still required
  String                                        $service_options = $haproxy::params::service_options,
  String                                        $sysconfig_options = $haproxy::params::sysconfig_options,
  # lint:endignore
) {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $service_manage {
    if ($facts['os']['family'] == 'Debian') {
      file { "/etc/default/${instance_name}":
        content => $service_options,
        before  => Service[$instance_name],
      }
    }
    if ($facts['os']['family'] == 'Redhat') {
      file { "/etc/sysconfig/${instance_name}":
        content => $sysconfig_options,
        before  => Service[$instance_name],
      }
    }

    $_service_enable = $service_ensure ? {
      'running' => true,
      'stopped' => false,
      default   => $service_ensure,
    }

    service { $instance_name:
      ensure     => $service_ensure,
      enable     => $_service_enable,
      name       => $instance_name,
      hasrestart => true,
      hasstatus  => true,
      restart    => $restart_command,
    }
  }
}
