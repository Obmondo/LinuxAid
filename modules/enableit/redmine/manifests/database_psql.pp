# Class redmine::database_psql
class redmine::database_psql {

    postgresql::server::db { [$redmine::production_database,$redmine::development_database]:
      user     => $redmine::database_user,
      password => postgresql_password($redmine::database_user, $redmine::database_password),
      encoding => 'utf8',
      require  => Class['postgresql::server']
    }

}
