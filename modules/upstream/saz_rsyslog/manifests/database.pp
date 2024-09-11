# == Class: saz_rsyslog::database
#
# Full description of class role here.
#
# === Parameters
#
# [*backend*]  - Which backend server to use (mysql|pgsql)
# [*server*]   - Server hostname
# [*database*] - Database name
# [*username*] - Database username
# [*password*] - Database password
#
# === Variables
#
# === Examples
#
#  class { 'saz_rsyslog::database':
#    backend  => 'mysql',
#    server   => 'localhost',
#    database => 'mydb',
#    username => 'myuser',
#    password => 'mypass',
#  }
#
class saz_rsyslog::database (
  $backend,
  $server,
  $database,
  $username,
  $password
) {
  include ::saz_rsyslog

  case $backend {
    'mysql': { $db_package = $saz_rsyslog::mysql_package_name }
    'pgsql': { $db_package = $saz_rsyslog::pgsql_package_name }
    default: { fail("Unsupported backend: ${backend}. Only MySQL (mysql) and PostgreSQL (pgsql) are supported.") }
  }

  package { $db_package:
    ensure => $saz_rsyslog::package_status,
  }

  saz_rsyslog::snippet { $backend:
    ensure    => present,
    file_mode => '0600',
    content   => template("${module_name}/database.conf.erb"),
    require   => Package[$db_package],
  }

}
