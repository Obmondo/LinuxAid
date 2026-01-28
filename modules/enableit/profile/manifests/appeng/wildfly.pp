# Wildfly class
class profile::wildfly (
  $version            = '8.2.0',
  $dirname            = '/opt/wildfly',
  $mode               = 'standalone',
  $config             = 'standalone-full.xml',
  $java_xmx           = '512m',
  $java_xms           = '256m',
  $java_maxpermsize   = '256m',
  $mgmt_http_port     = '9990',
  $mgmt_https_port    = '9993',
  $public_http_port   = '8080',
  $public_https_port  = '8443',
  $ajp_port           = '8009',
  $http_server        = 'apache',
  ) {

  validate_re($version, '^\d.\d.\d$')
  # 003 and 004 belongs to ssh and nrpe respectively
  firewall { '005 allow public http':   proto => 'tcp', port => '8080', jump => 'accept' }
  firewall { '006 allow public https':  proto => 'tcp', port => '8443', jump => 'accept' }
  firewall { '007 allow mgmt http':     proto => 'tcp', port => '9990', jump => 'accept' }
  firewall { '008 allow mgmt https':    proto => 'tcp', port => '9993', jump => 'accept' }

  package { [ 'tar', 'wget' ] : ensure => present }
  class { '::wildfly':
    version           => $version,
    install_source    => "http://download.jboss.org/wildfly/${version}.Final/wildfly-${version}.Final.tar.gz",
    group             => 'wildfly',
    user              => 'wildfly',
    dirname           => $dirname,
    mode              => $mode,
    config            => $config,
    java_home         => '',
    java_xmx          => $java_xmx,
    java_xms          => $java_xms,
    java_maxpermsize  => $java_maxpermsize,
    mgmt_http_port    => $mgmt_http_port,
    mgmt_https_port   => $mgmt_https_port,
    public_http_port  => $public_http_port,
    public_https_port => $public_https_port,
    ajp_port          => $ajp_port,
    users_mgmt        => {
      'wildfly' => {
        password => 'wildfly',
      },
    },
  }
  ::wildfly::util::resource { '/subsystem=undertow/server=default-server/ajp-listener=ajp':
    content => {
      'socket-binding' => 'ajp',
    },
  }

  # Setup web server
  case $http_server {
    'apache' : {
      class { '::profile::web::apache':
        ajp => true,
      }
    }
    'nginx' : {
      class { '::profile::web::nginx' : }
    }
    default : {
      fail("${http_server} is not supported yet")
    }
  }
}
