# Class: bind::service
#
class bind::service (
  $servicename,
  $service_reload,
) inherits ::bind::params {

  if $service_reload {
    Service[$servicename] {
      restart => "service ${servicename} reload",
    }
  }

  service { $servicename:
    ensure    => 'running',
    enable    => true,
    hasstatus => true,
    require   => Class['bind::package'],
  }
  
}
