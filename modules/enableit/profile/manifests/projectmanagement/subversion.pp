# Subversion enable
class profile::projectmanagement::subversion (
  Boolean                        $enable     = $role::projectmanagement::subversion::enable,
  Optional[Stdlib::Fqdn]         $domain     = $role::projectmanagement::subversion::domain,
  Optional[Stdlib::Absolutepath] $path       = $role::projectmanagement::subversion::path,
  Optional[Stdlib::Absolutepath] $dir        = $role::projectmanagement::subversion::dir,
  Optional[Stdlib::Absolutepath] $backup_dir = $role::projectmanagement::subversion::backup_dir,
  Optional[String]               $user       = $role::projectmanagement::subversion::user,
  Optional[String]               $password   = $role::projectmanagement::subversion::password,
  Eit_types::Noop_Value          $noop_value = $role::projectmanagement::subversion::noop_value,
) {

  Package {
    noop => $noop_value,
  }

  Service {
    noop => $noop_value,
  }

  Class { 'subversion':
    backupdir => $backup_dir,
    dir       => $dir,
  }

#  subversion::svnserve{ $domain :
#    source => "${domain}/svn",
#    path => "${path}",
#    user => "${user}",
#    password => "${password}"
#  }

}
