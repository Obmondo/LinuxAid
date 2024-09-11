class riemann::tools::install {
  include gcc

  ensure_resource('package', $riemann::params::libxml_package, {'ensure' => 'present' })
  ensure_resource('package', $riemann::params::libxslt_package, {'ensure' => 'present' })

  if $riemann::tools::health_enabled == true {
    user { $riemann::tools::health_user:
      ensure => present,
      system => true,
    }
  }

  if $riemann::tools::net_enabled == true {
    user { $riemann::tools::net_user:
      ensure => present,
      system => true,
    }
  }

  package { [
      'riemann-client',
      'riemann-tools',
    ]:
      ensure   => installed,
      provider => gem,
      require  => [
        Package[$riemann::params::libxml_package],
        Package[$riemann::params::libxslt_package],
      ],
  }
}
