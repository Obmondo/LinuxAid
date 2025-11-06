# Setup the xtrabackup script
class xtrabackup::install inherits xtrabackup {

  file { "${xtrabackup::backup_script_location}/xtrabackup.sh":
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => '0755',
    content => template('xtrabackup/xtrabackup.sh.erb'),
  }

  if $xtrabackup::install_xtrabackup_bin == true {
    package { 'percona-xtrabackup':
      ensure => $xtrabackup::package_version,
    }
  }
}
