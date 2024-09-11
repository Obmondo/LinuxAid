class riemann::tools::config {
  $health_enabled = $riemann::tools::health_enabled
  $net_enabled = $riemann::tools::net_enabled
  $net_user = $riemann::tools::net_user
  $health_user = $riemann::tools::health_user
  $rvm_ruby_string = $riemann::tools::rvm_ruby_string

  case $::osfamily {
    'Debian': {
      file { '/etc/init/riemann-health.conf':
        ensure  => present,
        content => template('riemann/etc/init/riemann-health.conf.erb'),
      }

      file { '/etc/init/riemann-net.conf':
        ensure  => present,
        content => template('riemann/etc/init/riemann-net.conf.erb'),
      }
    }
    'RedHat', 'Amazon': {
      $gem_path = $riemann::params::gem_path
      file { '/etc/init.d/riemann-net':
        ensure  => present,
        content => template('riemann/etc/init/riemann-net.conf.redhat.erb'),
        group   => root,
        owner   => root,
        mode    => '0755',
      }

      file { '/etc/init.d/riemann-health':
        ensure  => present,
        content => template('riemann/etc/init/riemann-health.conf.redhat.erb'),
        group   => root,
        owner   => root,
        mode    => '0755',
      }
    }
    default: {}
  }

}
