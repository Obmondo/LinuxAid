#
#this module is currently RHEL specific. filepaths - such as /etc/sysconfig/varnish should be looked up in hiera
#by Klavs Klavsen <klavs@EnableIT.dk>
#
#$malloc = 'malloc,6G',
class varnish (
  $secret,
  $backendip    ='none',
  $backendport  = 80,
  $listen       = '0.0.0.0:80',
  $vcl          = 'varnish/default.vcl',
  $malloc       = 'malloc,6G',
  $adminlistens = [],
) {

    package { 'varnish': }
    #ensure tmpfs to handle varnish _.vsm file
    file { "/var/lib/varnish/${::fqdn}":
      ensure  => directory,
      require => Package[varnish],
    }

    mount { "/var/lib/varnish/${::fqdn}":
      ensure   => 'mounted',
      fstype   => 'tmpfs',
      device   => 'tmpfs',
      options  => 'rw,size=256M',
      atboot   => true,
      remounts => true,
      require  => File["/var/lib/varnish/${::fqdn}"],
      notify   => Service[varnish],
    }
    service { 'varnish':
      ensure     => running,
      enable     => true,
      hasrestart => true,
      subscribe  =>  [File['/etc/varnish/default.vcl'],File['/etc/sysconfig/varnish']],
    }
    service { 'varnishncsa':
      ensure     => running,
      enable     => true,
      hasrestart => true,
      subscribe  => File['/etc/sysconfig/varnishncsa'],
    }

    file { '/etc/varnish/default.vcl':
      content => template($vcl),
      require => Package[varnish],
    }
    file { '/etc/varnish/secret':
      content => $secret,
      require => Package[varnish],
      mode    => '0600',
    }
    file { '/etc/sysconfig/varnish':
      content => template('varnish/varnish.erb'),
      require => Package[varnish],
    }
    file { '/etc/sysconfig/varnishncsa':
      source  => 'puppet:///modules/varnish/varnishncsa',
      require => Package[varnish],
    }
    file { '/etc/logrotate.d/varnish':
      source  => 'puppet:///modules/varnish/varnish-logrotate',
      require => Package[varnish],
    }
  }
