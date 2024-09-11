# Manage Guam one of kolab services
class kolab::guam {
  package { 'guam' : }

  file { '/etc/guam/sys.config' :
    ensure  => present,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template('kolab/guam.conf.erb'),
    require => Package['guam'],
    notify  => Service['guam'],
  }

  service { 'guam' :
    ensure    => running,
    enable    => true,
    require   => Package['guam'],
    subscribe => File['/etc/guam/sys.config'],
  }
}
