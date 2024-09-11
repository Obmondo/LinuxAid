# RTC in local TZ: no 
define profile::system::time::ntp::rtc (
  String $service_name,
) {

  exec { 'set-rtc-and-restart-service':
    command => "timedatectl set-local-rtc 0 --adjust-system-clock && systemctl restart ${service_name}",
    unless  => 'timedatectl status | grep "RTC in local TZ: no"',
    require => Service[$service_name],
  }
}
