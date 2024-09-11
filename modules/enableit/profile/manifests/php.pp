#generic php setup
#webserver part (in mod_php case) is done by profile::web::apache (only one with mod_php support)
# profiles MUST be feature based. ie. $opcodecache option (apc,xcache,none)
#- and NOT just a list of config settings, such as $modules..
#we then use $opcodecache setting to conclude WHAT modules should be loaded.
class profile::php (
  Boolean                             $ensure               = true,
  Eit_types::Timezone                 $date_timezone        = $::common::system::time::timezone,
  Boolean                             $ssl                  = false,
  Boolean                             $mysql                = false,
  Boolean                             $phpfpm               = false,
  Boolean                             $mod_php              = false,
  Boolean                             $composer             = false,
  Boolean                             $dev                  = false,
  Boolean                             $display_errors       = false,
  Boolean                             $expose_php           = false,
  Boolean                             $imagehandling        = true,
  Boolean                             $mssql                = false,
  Enum['syslog']                      $error_log            = 'syslog',
  Enum[ 'opcache', 'xcache', 'apc' ]  $opcodecache          = 'apc',
  Optional[Eit_types::Version]        $version              = undef,
  Optional[Stdlib::Absolutepath]      $config_root          = undef,
  Optional[Eit_types::Capacity]       $memory_limit         = '192M',
  Optional[Eit_types::Capacity]       $apc_shm_size         = '192M',
  Optional[Eit_types::Capacity]       $post_max_size        = '100M',
  Optional[Eit_types::Capacity]       $upload_max_filesize  = '100M',
  Hash[Eit_types::SimpleString, Hash] $modules              = {},
  Hash                                $phpfpm_settings      = {},
  Hash[Eit_types::SimpleString, Hash] $phpfpm_pool          = {
    'www' => $phpfpm_settings,
  },
) {

  # FIXME: Notify httpd/apache if used modules changes to it loads any changes

  # Setup the custom ini file for customer to have some extra settings
  file { '/opt/custom' :
    ensure => directory,
    owner  => 'root',
    group  => 'root',
  }

  file { '/opt/custom/php.ini' :
    ensure  => file,
    source  => 'puppet:///modules/profile/php/php.ini',
    replace => false,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File['/opt/custom'],
  }

  class { '::php::globals':
    php_version => $version,
    config_root => $config_root,
  }
  ->class { '::php':
    ensure       => ensure_present($ensure),
    manage_repos => false,
    fpm          => $phpfpm,
    fpm_pools    => if $phpfpm { $phpfpm_pool },
    composer     => $composer,
    dev          => $dev,
    settings     => {
      'PHP/display_errors'      => to_yesno($display_errors),
      'PHP/error_log'           => $error_log,
      'PHP/post_max_size'       => $post_max_size,
      'PHP/memory_limit'        => $memory_limit,
      'PHP/upload_max_filesize' => $upload_max_filesize,
      'PHP/expose_php'          => to_yesno($expose_php),
      'Date/date.timezone'      => $date_timezone,
    },
  }

  # Image Handling
  if $imagehandling {
    php::extension { lookup('package::php-imagick') :
      package_prefix => 'php-',
    }

    package::install('imagemagick')
  }

  # Modules
  deep_merge(lookup('profile::php::default_modules'), $modules).each |$module_name, $module_settings| {
    php::extension { $module_name:
      * => $module_settings
    }
  }

  if $mssql {
    contain ::profile::php::mssql
  }
}
