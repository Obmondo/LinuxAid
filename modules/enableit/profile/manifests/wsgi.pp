# WSGI profile
class profile::wsgi (
  Array[Stdlib::Fqdn]     $domains,
  Boolean                 $ssl         = false,
  Boolean                 $uwsgi       = false,
  Boolean                 $mod_wsgi    = false,
  Enum['nginx', 'apache'] $http_server = 'nginx'
) {

  #FIXME / TODO
  #selinux not yet supported under this profile
  #only solution to override common::system::selinux::enable setting - when this is used..
  #that I can think off.. would be hiera data in modules..  and make profiles::wsgi override user setting
  $docroot = '/var/www/html'
  $code = 'Python WSGI'
  $codeupcase = upcase($code)

  if ( $ssl ) {
    ensure_resource('firewall', '000 allow https', {
      proto  => 'tcp',
      dport  => 443,
      jump   => 'accept',
    })
  }

  ensure_resource('firewall', '000 allow http', {
    proto  => 'tcp',
    dport  => 80,
    jump   => 'accept',
  })

  if $uwsgi {
    $handler = 'uwsgi'

    # Setup uWSGI
    class { '::uwsgi' :
      package_provider => $facts['package_provider'],
      service_provider => $facts['service_provider'],
    }

    if $domains {
      File {
        default :
          ensure => directory,
        ;
        ['/var/www', $docroot] :
        ;
        [ "${docroot}/index.py" ] :
          ensure  => present,
          mode    => '0755',
          content => template('profile/index-html.erb'),
          require => File[$docroot]
        ;
      }

      uwsgi::app { 'sample_app' :
        ensure              => present,
        uid                 => 'uwsgi',
        gid                 => 'uwsgi',
        application_options => {
          socket      => '127.0.0.1:9090',
          plugins     => 'python',
          'wsgi-file' => '/var/www/html/index.py',
        },
      }

      # Apache
      if $http_server == 'apache' {
        # Setup apache
        if ( ! defined(Class['profile::web::apache']) ) {
          class { 'profile::web::apache' :
            uwsgi => true,
            https => $ssl
          }
        }

        # Setup the apache vhosts
        apache::vhost { $domains[0] :
          port          => '80',
          docroot       => $docroot,
          override      => 'all',
          serveraliases => $domains[1,-1],
          docroot_owner => 'root',
          docroot_group => 'root',
          proxy_pass    => [{
            'path' => '/',
            'url'  => 'uwsgi://127.0.0.1:9090',
          }],
        }
      }

      # Nginx
      if $http_server == 'nginx' {

        #FIXME test this selinux would work under apache as well,
        # Ideally it will but lets test it first
        if $facts['os']['selinux']['enabled'] {
          selinux::boolean { 'httpd_can_network_connect' :
            ensure => 'on',
          }
        }

        # TODO
        # Setup nginx to handle wsgi
        class { '::profile::web::nginx' : }

        nginx::resource::vhost { $domains[0] :
          listen_port => 80,
          www_root    => $docroot,
          server_name =>  $domains ,
          uwsgi       => '127.0.0.1:9090',
        }
      }
    }
  }

  if $mod_wsgi {
    $handler = 'mod_wsgi'

    if $http_server == 'apache' {
      # Setup apache
      class { 'profile::web::apache' :
        modules => [
          'wsgi'
        ],
        https   => $ssl,
        vhosts  => {},
      }

      if $domains {
        # Setup the apache vhosts
        apache::vhost { $domains[0] :
          port                => '80',
          docroot             => $docroot,
          override            => 'all',
          docroot_owner       => 'root',
          serveraliases       => $domains[1,-1],
          docroot_group       => 'root',
          wsgi_script_aliases => {
            '/' => '/var/www/html/index.wsgi',
          },
        }

        file { "${docroot}/index.wsgi" :
          ensure  => file,
          mode    => '0755',
          content => template('profile/index-html.erb'),
        }
      }

    } else {
      fail ('mod_wsgi is an apache specific module - nginx is NOT supported.')
    }
  }
}
