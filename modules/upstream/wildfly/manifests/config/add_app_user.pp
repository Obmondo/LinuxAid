#
# Add wildfly app user
#
define wildfly::config::add_app_user($username, $password) {

  wildfly::config::add_user { $name:
    username  => $username,
    password  => $password,
    file_name => 'application-users.properties',
    realm     => 'ApplicationRealm'
  }

}