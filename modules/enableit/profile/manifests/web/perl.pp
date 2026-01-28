#generic perl setup
class profile::perl (
  $url          = 'none',
  $cgi          = false,
  $fastcgi      = false,
  $mod_perl     = false,
  $http_server  = 'apache'
  ) {

  package { 'perl' : ensure => present }

  if $cgi {
    $handler = 'cgi-script'
    $custom_fragment = "
AddHandler ${handler} .cgi .pl"

    if $facts['os']['family'] == 'RedHat' {
      # Install CGI perl library
      package { 'perl-CGI' : ensure => present }
    }

    # Setup apache
    class { 'profile::web::apache' : }
  }

  if $fastcgi {
    $handler = 'fcgid-script'
    $custom_fragment = "
    AddHandler ${handler} .cgi .pl"

    # Install FCGI perl library
    package::install('perl_fcgi')

    # Setup apache with fcgid
    class { 'profile::web::apache' : fastcgi => true }
  }

  if $mod_perl {
    $handler = 'mod_perl'
    $custom_fragment = '
    SetHandler perl-script
    PerlResponseHandler ModPerl::Registry
    PerlOptions +ParseHeaders'

    # Setup apache with mod_perl
    class { 'profile::web::apache' : perl => true }
  }

  if $url != 'none' {
    $docroot = '/var/www/html'
    $code = 'perl'
    $codeupcase = upcase($code)

    if $http_server == 'apache' {
      # Setup the apache vhosts
      apache::vhost { $url :
        port          => '80',
        docroot       => $docroot,
        override      => 'all',
        docroot_owner => 'root',
        docroot_group => 'root',
        directories   => [
          {
            path            => $docroot,
            options         => [ 'ExecCGI', 'Indexes','FollowSymLinks','MultiViews'],
            custom_fragment => $custom_fragment
          }
        ],
        notify        => File["${docroot}/index.pl"],
      }
    }

    if $http_server == 'nginx' {
      nginx::resource::vhost { $url:
        listen_port => 80,
        www_root    => $docroot,
        server_name => $url,
        notify      => File["${docroot}/index.pl"],
      }
    }

    file { "${docroot}/index.pl" :
      ensure  => file,
      mode    => '0755',
      content => template('profile/index-html.erb'),
    }
  }
}
