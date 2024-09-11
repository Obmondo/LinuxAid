# jenkins profile
class profile::ci::jenkins (
  String                      $ssl_combined_pem,
  Eit_types::Version          $version     = 'installed',
  Hash                        $config_hash = {},
  Eit_types::Jenkins::Plugins $plugins     = {},
  Stdlib::Port                $port        = 8080,
) inherits ::profile {

  class { 'jenkins':
    version        => $version,
    lts            => true,
    repo           => true,
    port           => $port,
    service_enable => true,
    config_hash    => $config_hash,
    localstatedir  => '/var/lib/jenkins',
    user           => 'jenkins',
    manage_user    => true,
    group          => 'jenkins',
    manage_group   => true,
  }

  $plugins.each |$_plugin, $_settings| {
    jenkins::plugin { $_plugin:
      * => $_settings,
    }
  }

  # Setup haproxy https
  file {
    '/etc/ssl/private/jenkins':
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0500',
      ;

    '/etc/ssl/private/jenkins/combined.pem':
      ensure  => present,
      content => $ssl_combined_pem,
      mode    => '0400',
      before  => Class['haproxy'],
      require => File['/etc/ssl/private/jenkins'],
      ;
  }

  class { '::eit_haproxy::auto_config' :
    encryption_ciphers => 'strict',
    redirect_http      => true,
    proxies            => {
      jenkins_http => {
        letsencrypt   => false,
        mode          => 'http',
        binds         => {
          https_0_0_0_0_80  => {
            'ports'     => [80],
            'ssl'       => false,
            'ipaddress' => '0.0.0.0',
          },
          https_0_0_0_0_443 => {
            'ports'     => [443],
            'ssl'       => true,
            'options'   => 'crt /etc/ssl/private/jenkins/combined.pem',
            'ipaddress' => '0.0.0.0',
          },
        },
        sites         => {
          jenkins_http => {
            servers         => [
              "127.0.0.1:${port}",
            ],
            default_backend => true,
          },
        },
        extra_options => {
          option => ['forwardfor'],
        }
      }
    },
  }

}
