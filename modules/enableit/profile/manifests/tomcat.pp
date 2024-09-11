# Tomcat profile
class profile::tomcat (
  $http_port                = '8080',
  $ajp_port                 = '8009',
  $ajp_host                 = 'localhost',
  Integer[6,7] $version     = 7,
  $http_server              = 'apache',
  $install_from_source      = false,
  ) {

  case $version {
    6 : {
      case $::osfamily {
        'Debian' : {
          package { ['tomcat6-admin', 'tomcat6-common' ] :
            ensure  => present,
            require => Tomcat::Instance['default'],
          }
          $package_name = "tomcat${version}"
          $catalina_base = "tomcat${version}"
        }
        'RedHat' : {
          package { [ 'tomcat6-admin-webapps', 'tomcat6-webapps' ] :
            ensure  => present,
            require => Tomcat::Instance['default'],
          }
          $catalina_base = "tomcat${version}"
          $package_name = "tomcat${version}"
        }
        default : {
          fail("${::operatingsystem} not support, Please contact obomdo.com")
        }
      }
    }
    7 : {
      case $::osfamily {
        'Debian' : {
          package { ['tomcat7-admin', 'tomcat7-common' ] :
            ensure  => present,
            require => Tomcat::Instance['default'],
          }
          $package_name = "tomcat${version}"
          $catalina_base = "tomcat${version}"
        }
        'RedHat' : {
          package { [ 'tomcat-admin-webapps', 'tomcat-webapps' ] :
            ensure  => present,
            require => Tomcat::Instance['default'],
          }
          $package_name = 'tomcat'
          $catalina_base = 'tomcat'
        }
        default : {
          fail("${::operatingsystem} not support, Please contact obomdo.com")
        }
      }
    }
    8 : {
      case $::osfamily {
        'Debian' : {
          fail('Not Supported Yet')
        }
        'RedHat' : {
          fail('Not Supported Yet')
        }
        default : {
          fail("${::operatingsystem} not support, Please contact obomdo.com")
        }
      }
    }
    default: {
      fail("${version} is not supported yet")
    }
  }

  class { '::tomcat': }

  # Setup web server
  case $http_server {
    'apache' : {
      class { '::profile::web::apache': ajp => true }
    }
    'nginx' : {
      class { '::profile::web::nginx' : }
    }
    default: {
      fail("${http_server} is not supported yet")
    }
  }

  tomcat::instance { 'default' :
    catalina_home       => "/etc/${catalina_base}",
    install_from_source => $install_from_source,
    package_name        => $package_name,
    require             => Class[::profile::java],
  }
  -> tomcat::config::server { 'default' :
    catalina_base => "/etc/${catalina_base}",
    server_config => "/etc/${catalina_base}/server.xml",
    port          => '8005',
    address       => '127.0.0.1',
  }
  -> tomcat::config::server::connector { 'default-http' :
    additional_attributes => {
      'address' => '127.0.0.1',
    },
    catalina_base         => "/etc/${catalina_base}",
    server_config         => "/etc/${catalina_base}/server.xml",
    port                  => $http_port,
    protocol              => 'HTTP/1.1',
    connector_ensure      => 'present',
    notify                => Tomcat::Service['default'],
  }
  -> tomcat::config::server::connector { 'default-ajp' :
    additional_attributes => {
      'address' => '127.0.0.1',
    },
    catalina_base         => "/etc/${catalina_base}",
    server_config         => "/etc/${catalina_base}/server.xml",
    port                  => $ajp_port,
    protocol              => 'AJP/1.3',
    connector_ensure      => 'present',
    notify                => Tomcat::Service['default'],
  }
  -> tomcat::service { 'default':
    service_name => $catalina_base,
    use_init     => true,
  }
}
