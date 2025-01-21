# Config file for apache setup
class passenger::config (
  $manage_web_server = false
  ) {

  if $manage_web_server {
    File { notify => Class['apache::service'] }
  }

  case $facts['os']['family'] {
    'Debian': {
      file { '/etc/apache2/mods-available/passenger.load':
        ensure  => present,
        content => template('passenger/passenger-load.erb'),
        owner   => '0',
        group   => '0',
        mode    => '0644'
      }

      file { '/etc/apache2/mods-available/passenger.conf':
        ensure  => present,
        content => template('passenger/passenger-enabled.erb'),
        owner   => '0',
        group   => '0',
        mode    => '0644'
      }

      file { '/etc/apache2/mods-enabled/passenger.load':
        ensure  => 'link',
        target  => '/etc/apache2/mods-available/passenger.load',
        owner   => '0',
        group   => '0',
        mode    => '0777',
        require => File['/etc/apache2/mods-available/passenger.load']
      }

      file { '/etc/apache2/mods-enabled/passenger.conf':
        ensure  => 'link',
        target  => '/etc/apache2/mods-available/passenger.conf',
        owner   => '0',
        group   => '0',
        mode    => '0777',
        require => File['/etc/apache2/mods-available/passenger.conf'],
      }
    }
    'RedHat': {

      file { '/etc/httpd/conf.d/passenger.conf':
        ensure  => present,
        content => template('passenger/passenger-load.erb', 'passenger/passenger-enabled.erb'),
        owner   => '0',
        group   => '0',
        mode    => '0644',
      }
    }
    default:{
      fail("Operating system ${facts['os']['family']} is not supported with the Passenger module")
    }
  }

}
