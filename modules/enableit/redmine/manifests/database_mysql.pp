# Class redmine::database_mysql
class redmine::database_mysql {

    Mysql_database {
      require => Class['mysql::server']
    }

    mysql_database { [$redmine::production_database,$redmine::development_database]:
      ensure  => present,
      charset => 'utf8'
    }

    -> mysql_user { "${redmine::database_user}@${redmine::database_server}":
      password_hash => mysql_password($redmine::database_password)
    }

    -> mysql_grant { "${redmine::database_user}@${redmine::database_server}/${redmine::production_database}.*":
      user       => "${redmine::database_user}@${redmine::database_server}",
      privileges => ['all'],
      table      => "${redmine::production_database}.*"
    }

    -> mysql_grant { "${redmine::database_user}@${redmine::database_server}/${redmine::development_database}.*":
      user       => "${redmine::database_user}@${redmine::database_server}",
      privileges => ['all'],
      table      => "${redmine::development_database}.*"
    }

}
