class riemann::dash::config {
  $host = $riemann::dash::host
  $port = $riemann::dash::port
  $user = $riemann::dash::user
  $rvm_ruby_string = $riemann::dash::rvm_ruby_string

  case $::osfamily {
    'Debian': {
      file { '/etc/init.d/riemann-dash':
        ensure => link,
        target => '/lib/init/upstart-job',
      }

      file { '/etc/init/riemann-dash.conf':
        ensure  => present,
        content => template('riemann/etc/init/riemann-dash.conf.erb'),
      }
    }
    'RedHat', 'Amazon': {
      $gem_path = $riemann::params::gem_path
      file { '/etc/init.d/riemann-dash':
        ensure  => present,
        mode    => '0755',
        content => template('riemann/etc/init/riemann-dash.conf.redhat.erb'),
      }
    }
    default: {}
  }

  file { '/etc/riemann-dash.rb':
    ensure  => present,
    content => template('riemann/etc/riemann-dash.rb.erb'),
  }
}
