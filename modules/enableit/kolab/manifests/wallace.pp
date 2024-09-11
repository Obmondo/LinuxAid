# Manage wallace
class kolab::wallace {
  package { 'wallace' : }
  service { 'wallace' :
    ensure  => running,
    enable  => true,
    require => Package['wallace']
  }
}
