# Manage manticore
class kolab::manticore {
  package { 'manticore' : }

  service { 'manticore' :
    ensure  => running,
    enable  => true,
    require => Package['manticore']
  }
}
