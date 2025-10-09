#
# Manages a Management User (`mgmt-users.properties`) for Wildfly.
#
# @param password The user password.
define wildfly::config::mgmt_user(String $password) {

  wildfly::config::user { "${title}:ManagementRealm":
    password  => $password,
    file_name => 'mgmt-users.properties',
  }

}
