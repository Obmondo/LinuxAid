# haproxy Service
class eit_haproxy::service (
  Eit_types::Service_Ensure $ensure             = $::eit_haproxy::service_ensure,
  Eit_types::Service_Enable $enable             = $::eit_haproxy::service_enable,
  String                    $service_name       = $::eit_haproxy::service_name,
  Optional[String]          $restart_command    = $::eit_haproxy::restart_command,
  Hash                      $service_options    = $::eit_haproxy::service_options,
  String                    $defaults_file_path = $::eit_haproxy::defaults_file_path,
) {

  $service_options.each |$setting, $value| {
    ini_setting { "${setting}_${value}":
      ensure  => present,
      path    => "${defaults_file_path}/${service_name}",
      setting => $setting,
      value   => $value,
      notify  => Service[$service_name],
    }
  }

  service { $service_name:
    ensure     => $ensure,
    enable     => $enable,
    name       => $service_name,
    hasrestart => true,
    hasstatus  => true,
    restart    => $restart_command,
    require    => Package[$::eit_haproxy::install::package_name],
  }
}
