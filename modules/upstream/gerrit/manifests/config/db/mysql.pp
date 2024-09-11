# == Class: gerrit::config::db::mysql
#
# This class exports a DB configuration for the puppetlabs/mysql module
# provided that managa_database is true (default)
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
class gerrit::config::db::mysql {
  if ($gerrit::manage_database) {
    $options = $gerrit::options
    $secure_options = $gerrit::config::real_secure_options

    validate_string($options['database']['database'])
    validate_string($options['database']['hostname'])
    validate_string($options['database']['username'])
    validate_string($secure_options['database']['password'])

    $database = $options['database']['database']
    $username = $options['database']['username']
    $password = $secure_options['database']['password']

    @@::mysql::db { "${database}_${::fqdn}":
      user     => $username,
      password => $password,
      dbname   => $database,
      host     => $::ipaddress,
      grant    => [ 'ALL' ],
      tag      => $gerrit::db_tag,
    }
  }
}
