#
# Manages an Application User (`application-users.properties`) for Wildfly.
#
# @param password The user password.
define wildfly::config::app_user(String $password) {

  wildfly::config::user { "${title}:ApplicationRealm":
    password  => $password,
    file_name => 'application-users.properties',
  }

}
