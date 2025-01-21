# Install passenger moduel for apachr or nginx
class passenger::compile (
  $mod_passenger  = undef,
  $webserver      = 'apache'
  ) {

  case $webserver {
    'apache'  : { $web = 'apache2' }
    'nginx'   : { $web = 'nginx' }
    default   : { fail('Not Supported') }
  }

  case $facts['os']['family'] {
    'Debian' : { $verify_command = 'apache2ctl' }
    'RedHat' : { $verify_command = 'apachectl'  }
    default  : { fail('Not Supported') }
  }

  # Default path for exec resource
  Exec { path => [ '/usr/bin', '/usr/sbin', '/bin', '/usr/local/bin' ] }

  ##################################
  #TODO add support for nginx #TODO#
  ##################################

  # apache config test
  exec { 'apache-configtest' :
    command => "${verify_command} -t",
    unless  => "test -f ${mod_passenger}",
    notify  => Exec['compile-passenger-for-apache']
  }

  # build the apache module for passenger
  exec {'compile-passenger-for-apache':
    command   => "passenger-install-${web}-module -a",
    logoutput => on_failure,
    timeout   => 1000,
    unless    => "test -f ${mod_passenger}",
    require   => Exec['apache-configtest'],
    notify    => Exec['smoke test for passenger installation']
  }

  # Testing the installtion
  exec { 'smoke test for passenger installation' :
    command => 'passenger-config validate-install --auto',
    unless  => "test -f ${mod_passenger}",
    timeout => '60',
    require => Exec['compile-passenger-for-apache']
  }
}
