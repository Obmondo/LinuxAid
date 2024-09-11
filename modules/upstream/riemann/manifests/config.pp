class riemann::config (
  Eit_types::File_Ensure $ensure,
) {
  file { '/etc/systemd/system/riemann.service':
    ensure => $ensure,
    source => 'puppet:///modules/riemann/riemann.service',
  }

  file { '/etc/riemann/riemann.config.sample':
    ensure  => $ensure,
    content => 'puppet:///modules/riemann/riemann.config.sample'
  }

}
