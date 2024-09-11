node default {
  include stunnel
  Stunnel::Tun {
    require => Package[$stunnel::data::package],
    notify => Service[$stunnel::data::service],
  }
  stunnel::tun { 'rsyncd':
    certificate => "/etc/puppet/ssl/certs/${::clientcert}.pem",
    private_key => "/etc/puppet/ssl/private_keys/${::clientcert}.pem",
    ca_file     => '/etc/puppet/ssl/certs/ca.pem',
    crl_file    => '/etc/puppet/ssl/crl.pem',
    chroot      => '/var/lib/stunnel4/rsyncd',
    user        => 'puppet',
    group       => 'puppet',
    client      => false,
    accept      => '1873',
    connect     => '873',
  }
  stunnel::tun { 'rsync':
    certificate => "/etc/puppet/ssl/certs/${::clientcert}.pem",
    private_key => "/etc/puppet/ssl/private_keys/${::clientcert}.pem",
    ca_file     => '/etc/puppet/ssl/certs/ca.pem',
    crl_file    => '/etc/puppet/ssl/crl.pem',
    chroot      => '/var/lib/stunnel4/rsync',
    user        => 'puppet',
    group       => 'puppet',
    client      => true,
    accept      => '1874',
    connect     => 'server.example.com:1873',
  }
}
