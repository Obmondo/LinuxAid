# ==Class: subversion::backup
#
# This class will add a shell script based on the utility hot-backup.py to make
# consitent backups each night.
#
# Parameters:
#  $subversion_backupdir:
#    global variable that sets the backup directory
#  $subversion_dir:
#    global variable that sets the base repositories directory
#
class subversion::backup (
  $backupdir = $subversion::backupdir,
  $dir = $subversion::dir,
) {

  validate_absolute_path($backupdir)
  validate_absolute_path($dir)

  $hotbackupname = $facts['os']['family'] ? {
    'Debian' => 'svn-hot-backup',
    'RedHat' => 'hot-backup.py',
  }

  file {$backupdir:
    ensure => directory,
    owner  => root,
    group  => root,
    mode   => '0755',
  }

  file { '/usr/local/bin/subversion-backup.sh':
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0755',
    content => template('subversion/subversion-backup.sh.erb'),
    require => [ Package['subversion-tools'], File[$backupdir] ],
  }

  cron { 'subversion-backup':
    command => '/usr/local/bin/subversion-backup.sh',
    user    => 'root',
    hour    => 2,
    minute  => 0,
    require => [File['/usr/local/bin/subversion-backup.sh']],
  }

}
