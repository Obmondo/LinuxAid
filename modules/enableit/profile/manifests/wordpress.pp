# Wordpress profile
class profile::wordpress (
  Boolean $ssl                               = false,
  Boolean $multisite                         = false,
  Optional[Eit_types::Hostname] $site_domain = undef,
  $http_server                               = 'apache',
  Enum['mysql'] $dbdriver                    = 'mysql',
  $url                                       = "wordpress.${facts['networking']['domain']}",
  $php                                       = '::role::appeng::mod_php',
  Boolean $force_https                       = false,
  Stdlib::Absolutepath $install_dir          = '/var/www/wordpress',
) {

  confine($multisite, !$site_domain, 'When using multisite, `site_domain` must be provided')

  include ::common::settings

  # Need tar package to untar wordpress source ball
  package { 'tar' : ensure => present }
  if ( ! defined(Package['wget']) ) {
    package { 'wget' : ensure => present }
  }

  $wp_owner = $php ? {
    '::role::appeng::mod_php' => $::apache::params::user,
    '::role::appeng::phpfpm'  => 'phpfpm',
    default                 => 'www-data',
  }

  # Setup wordpress
  class { '::wordpress' :
    wp_owner             => $wp_owner,
    wp_group             => $wp_owner,
    wp_multisite         => $multisite,
    wp_site_domain       => $site_domain,
    wp_additional_config => epp('profile/profile_wordpress.epp'),
    install_dir          => $install_dir,
    require              => [
      Package['tar'],
      Class["profile::${http_server}"],
    ],
  }

  if $http_server == 'apache' {
    # Pass phpfpm config, only when phpfpm is running
    $proxy_pass_match = $php ? {
      '::role::appeng::phpfpm' => [
        {
        'path' => '^/(.*\.php)$',
        'url' => 'fcgi://127.0.0.1:9001/var/www/wordpress/$1',
        }],
      default => undef,
    }

    if $ssl {
      apache::vhost { "${url}_443" :
        ssl              => $ssl,
        port             => 443,
        servername       => $url,
        docroot          => $install_dir,
        docroot_owner    => $wp_owner,
        docroot_group    => $wp_owner,
        override         => [ 'FileInfo' ],
        proxy_pass_match => $proxy_pass_match,
        require          => Class['profile::web::apache'],
        before           => Class['::wordpress'],
      }
    }

    # Setup the apache vhosts
    apache::vhost { $url :
      port             => 80,
      docroot          => $install_dir,
      docroot_owner    => $wp_owner,
      docroot_group    => $wp_owner,
      override         => [ 'FileInfo' ],
      proxy_pass_match => $proxy_pass_match,
      require          => Class['profile::web::apache'],
      before           => Class['::wordpress'],
    }
  }

  # local wordpress customization
  file { "${common::settings::custom_config_dir}/wordpress":
    ensure => directory,
  }

  file { "${common::settings::custom_config_dir}/wordpress/wp-config-local.php":
    ensure => file,
  }
}
