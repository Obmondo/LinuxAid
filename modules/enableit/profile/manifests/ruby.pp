# Ruby profile
class profile::ruby (
  $url                  = 'none',
  $role                 = 'passenger',
  $compile              = 'apache',
  $passenger_name       = 'passenger',
  $passenger_version    = 'present',
  $passenger_provider   = undef
) {

  # Setup Apache/Nginx vhost
  # TODO

  case $role {
    'passenger' : {
      class { 'profile::passenger' :
        compile            => $compile,
        passenger_name     => $passenger_name,
        passenger_version  => $passenger_version,
        passenger_provider => $passenger_provider,
      }
    }
    default : {
      fail("This ${role} is not supported, Please select different role")
    }
  }
}
