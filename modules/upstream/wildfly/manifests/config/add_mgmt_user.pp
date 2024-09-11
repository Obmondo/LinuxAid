#
# Add wildfly management user
#
define wildfly::config::add_mgmt_user($username, $password) {

  wildfly::config::add_user { $name:
    username  => $username,
    password  => $password,
    file_name => 'mgmt-users.properties',
    realm     => 'ManagementRealm'
  }

}