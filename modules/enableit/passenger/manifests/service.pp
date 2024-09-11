# Manage webservers
class passenger::service (
  $webserver = 'apache'
  ) {
  case $webserver {
    'apache' : { class { 'profile::web::apache': } }
    'nginx'  : { class { 'profile::web::nginx' : } }
    default  : { fail("Not Supported ${webserver}") }
  }
}
