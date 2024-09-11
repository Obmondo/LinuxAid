# == Class: gerrit::config::db
#
# This class pulls in the appropriate submodule for database management
# based upon the $options[database][type] attribute
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
class gerrit::config::db {
  Class['gerrit::config::db'] -> Class['gerrit::initialize']

  $options = $gerrit::options

  # Determine what database configuration to include
  # We only "manage" mysql and posgresql types and really only flags for
  # managing the DB are set
  if $options['database'] {
    case upcase($options['database']['type']) {
      'MYSQL':      { include ::gerrit::config::db::mysql }
      'POSTGRESQL': { include ::gerrit::config::db::postgresql }
      default:      { }
    }
  }
}
