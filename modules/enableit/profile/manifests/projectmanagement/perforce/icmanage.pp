# ICManage on top of Perforce
class profile::projectmanagement::perforce::icmanage (
  Integer[0,default]       $version           = $::role::projectmanagement::perforce::icmanage::version,
  Stdlib::Absolutepath     $install_path      = $::role::projectmanagement::perforce::icmanage::install_path,

  Stdlib::Host             $hostname          = $::role::projectmanagement::perforce::icmanage::hostname,

  Boolean                  $manage_db         = $::role::projectmanagement::perforce::icmanage::manage_db,
  Eit_types::Password      $root_password     = $::role::projectmanagement::perforce::icmanage::root_password,
  Eit_types::SimpleString  $db_user           = $::role::projectmanagement::perforce::icmanage::db_user,
  Eit_types::Password      $db_password       = $::role::projectmanagement::perforce::icmanage::db_password,
  Boolean                  $db_backup         = $::role::projectmanagement::perforce::icmanage::db_backup,

  Eit_types::SimpleString  $db_admin_user     = $::role::projectmanagement::perforce::icmanage::db_admin_user,
  Eit_types::Password      $db_admin_password = $::role::projectmanagement::perforce::icmanage::db_admin_password,
  Eit_types::SimpleString  $db_charset        = $::role::projectmanagement::perforce::icmanage::db_charset,
  Eit_types::SimpleString  $db_collate        = $::role::projectmanagement::perforce::icmanage::db_collate,

  Stdlib::Absolutepath     $config_file       = '/etc/icmanage/icmPm.cfg',

  String                   $mysql_version     = $::role::projectmanagement::perforce::icmanage::mysql_version,
  Stdlib::Absolutepath     $backup_dir        = $::role::projectmanagement::perforce::icmanage::backup_dir,
  Array[Eit_types::IPCIDR] $access_mysql_from = $::role::projectmanagement::perforce::icmanage::access_mysql_from,
) inherits ::profile::projectmanagement::perforce {

  # Monitoring
  if $manage_db {

    class { '::profile::mysql' :
      backup         => $db_backup,
      package_ensure => $mysql_version,
    }

    mysql_user { "${db_admin_user}@%":
      ensure        => present,
      password_hash => mysql::password($db_admin_password),
      require       => Class['profile::mysql'],
    }

    mysql::db { 'bugs':
      user     => $db_admin_user,
      password => $db_admin_password,
      host     => 'localhost',
      grant    => 'ALL',
      charset  => $db_charset,
      collate  => $db_collate,
      require  => Mysql_user["${db_admin_user}@%"],
    }

    mysql_grant { "${db_user}@%/bugs.*":
      user       => "${db_user}@%",
      table      => 'bugs.*',
      privileges => [
        'SELECT',
        'INSERT',
        'UPDATE',
        'DELETE',
        'CREATE VIEW',
        'CREATE',
        'INDEX',
        'EXECUTE',
      ],
      require    => Mysql::Db['bugs'],
    }
  }

  $_icm_installer = "icm.rhel${facts['os']['release']['major']}.${version}.run"
  $_installer_tmp_file = "/tmp/${_icm_installer}"

  exec { 'test if icmanage is installed':
    command => '/bin/true',
    onlyif  => "/usr/bin/test ! -d ${install_path}",
  }

  archive { $_installer_tmp_file:
    ensure  => 'present',
    source  => "https://download.icmanage.com/${_icm_installer}",
    require => Exec['test if icmanage is installed'],
  }

  exec { "install icmanage ${version}":
    command => "/bin/sh ${_installer_tmp_file} --baseDirPath ${install_path}",
    onlyif  => "/usr/bin/test ! -d ${install_path}",
    require => Archive[$_installer_tmp_file],
  }

  $_config_dir = $config_file.dirname
  file { $_config_dir:
    ensure => directory,
    before => File[$config_file],
  }

  functions::create_ini_file($config_file, {
    'icm.host'       => $hostname,
    'mysql.user'     => $db_admin_user,
    'mysql.password' => $db_admin_password,
  })

}
