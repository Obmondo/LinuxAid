class subversion::base {
  package{'subversion':
    ensure => present,
  }

  file { '/etc/subversion':
    ensure  => directory,
    require => Package['subversion'],
  }

  augeas::lens {'subversion':
    ensure       => present,
    lens_content => file('subversion/subversion.aug'),
    stock_since  => '1.0.0',
  }

  $osrelease = $facts['os']['release']['major']

  $changes = "$facts['os']['name']${osrelease}" ? {
    default                       => 'set auth/store-auth-creds no',
    /^(RedHat5|Debian5|Debian6)$/ => 'set auth/store-password no',
  }

  # only recent version of svn support the "store-password" option.
  augeas { 'avoid svn password saving':
    incl    => '/etc/subversion/config',
    lens    => 'Subversion.lns',
    require => [Augeas::Lens['subversion'], File['/etc/subversion']],
    changes => $changes,
  }
}
