# Create Postfix virtual aliases
class postfix::virtualalias (
  Hash $virtual
) {

  File { '/etc/postfix/virtual' :
    ensure  => present,
    mode    => '0644',
    content => template('postfix/virtual.erb'),
  }

  Exec { 'postmap_update' :
    path        => ['/usr/local/sbin', '/usr/local/bin', '/usr/sbin', '/usr/bin', '/sbin', '/bin'],
    command     => 'postmap /etc/postfix/virtual',
    subscribe   => File['/etc/postfix/virtual'],
    refreshonly => true,
  }
}
