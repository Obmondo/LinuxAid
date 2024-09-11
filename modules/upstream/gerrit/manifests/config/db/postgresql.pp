# == Class: gerrit::config::db::postgresql
#
# This class exports a DB configuration for the puppetlabs/postgresql
# module provided that managa_database is true (default)
#
# === Parameters
#
# This module does not accept any parameters
#
# === Variables
#
# This module does not accept any variables
#
# === Authors
#
# Andrew Grimberg <agrimberg@linuxfoundation.org>
#
# === Copyright
#
# Copyright 2014 Andrew Grimberg
#
class gerrit::config::db::postgresql {
  if ($gerrit::manage_database) {
    $options = $gerrit::options
    $secure_options = $gerrit::config::real_secure_options

    validate_string($options['database']['database'])
    validate_string($options['database']['hostname'])
    validate_string($options['database']['username'])
    validate_string($secure_options['database']['password'])

    $database = $options['database']['database']
    $hostname = $options['database']['hostname']
    $username = $options['database']['username']
    $password = $secure_options['database']['password']

    # export valid postgresql database configuration

#    @@mysql::db { "${database}_${fqdn}":
#      user     => $username,
#      password => $password,
#      dbname   => $database,
#      host     => $hostname,
#      grant    => [ 'ALL' ],
#      tag      => $gerrit::db_tag,
#    }
  }
}

