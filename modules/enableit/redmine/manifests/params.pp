# Class redmine::params
class redmine::params {

  case $facts['os']['family'] {
    'RedHat': {
      case $facts['os']['family'] {
        'Fedora': {
          if versioncmp($facts['os']['release']['full'], '19') >= 0 or $facts['os']['release']['full'] == 'Rawhide' {
            $mysql_devel = 'mariadb-devel'
          } else {
            $mysql_devel = 'mysql-devel'
          }
        }
        /^(RedHat|CentOS|Scientific)$/: {
          if versioncmp($facts['os']['release']['major'], '7') >= 0 {
            $mysql_devel = 'mariadb-devel'
          } else {
            $mysql_devel = 'mysql-devel'
          }
        }
        default: {
          $mysql_devel = 'mysql-devel'
        }
      }
    }
    default: {
      notice("nothing special for ${facts['os']['family']}")
    }
  }

  if $redmine::database_adapter {
    $real_adapter = $redmine::database_adapter
  } elsif versioncmp($facts['ruby']['version'], '1.9') >= 0 {
    $real_adapter = 'mysql2'
  } else {
    $real_adapter = 'mysql'
  }

  if $redmine::version {
    $version = $redmine::version
  } else {
    $version = '2.2.3'
    warning('The default version will change to 2.6.4 in the next major release')
    warning('If this is not what you want, please specify a version in hiera or your manifest')
  }

  case $redmine::provider {
    'svn' : {
      $provider_package = 'subversion'
    }
    'hg': {
      $provider_package = 'mercurial'
    }
    default: {
      $provider_package = $redmine::provider
    }
  }
}
