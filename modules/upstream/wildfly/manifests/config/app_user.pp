#
# Add wildfly app user
#
define wildfly::config::app_user($password) {

  wildfly::config::user { $name:
    username  => $name,
    password  => $password,
    file_name => 'application-users.properties',
    realm     => 'ApplicationRealm'
  }

}
