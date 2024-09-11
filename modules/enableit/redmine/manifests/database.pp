# Class redmine::database
class redmine::database {

  if $redmine::database_server == 'localhost' {
    if $redmine::params::real_adapter == 'postgresql' {
      class { 'redmine::database_psql': }
    } else {
      class { 'redmine::database_mysql': }
    }
  }

}
