#Phpmyadmin installation parameters
#Sets variables for both centos/redhat and ubuntu OS versions currently

class phpmyadmin::params {
  include ::apache::params

  #Class defaults
  $apache_name = $::apache::params::apache_name
  $disable_mod_security = hiera('phpmyadmin::disable_mod_security', false)

  #Per OS variables
  case $::osfamily {
    'RedHat': {
      $package_name          = 'phpMyAdmin'
      $site_enable_dir       = $::apache::params::confd_dir
      $apache_default_config = "${site_enable_dir}/phpMyAdmin.conf"
      $config_file           = '/etc/phpMyAdmin/config.inc.php'
      $doc_path              = '/usr/share/phpMyAdmin'
      $data_dir              = '/var/lib/phpMyAdmin'
      $preseed_package       = false
    }
    'Debian': {
      $package_name          = 'phpmyadmin'
      $site_enable_dir       = $::apache::params::vhost_enable_dir
      $apache_default_config = "${::apache::params::confd_dir}/phpmyadmin.conf"
      $config_file           = '/etc/phpmyadmin/config.inc.php'
      $doc_path              = '/usr/share/phpmyadmin'
      $data_dir              = '/var/lib/phpmyadmin'
      $preseed_package       = true
      $debconf_package       = 'debconf-utils'
    }
    default: {
      fail("Class['phpmyadmin::params']: Unsupported OS: ${::osfamily}")
    }
  }
}