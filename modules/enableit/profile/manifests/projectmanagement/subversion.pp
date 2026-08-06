# Subversion enable
class profile::projectmanagement::subversion {

  $noop_value = false

  Package {
    noop => $noop_value,
  }

  Service {
    noop => $noop_value,
  }

  Class { 'subversion':
    backupdir => '/var/www/svn/backup',
    dir       => '/repos',
  }

}
