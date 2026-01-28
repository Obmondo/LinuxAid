# Passenger Profile
class profile::passenger (
  $url                  = undef,
  $http_server          = 'apache',
  $passenger_name       = 'passenger',
  $passenger_version    = 5,
  $passenger_provider   = undef,
  $manage_web_server    = false
  ) {

  # If web is setup by mysql, then dont setup by pasenger module
  $check_apache = getvar('profile::mysql::web')
  if $check_apache {
    $_manage_web_server = false
  } else {
    $_manage_web_server = $manage_web_server
  }

  class { '::passenger' :
    compile            => $http_server,
    passenger_name     => $passenger_name,
    passenger_version  => $passenger_version,
    passenger_provider => $passenger_provider,
    manage_web_server  => $_manage_web_server,
  }
}
