#
define wildfly::security::user_role_mapping($role, $username = $title, $realm = undef) {

  $_username = upcase($username)

  wildfly::util::resource { "/core-service=management/access=authorization/role-mapping=${role}/include=user-${_username}":
    content => {
      'name'  => $username,
      'realm' => $realm,
      'type'  => 'USER',
    },
  }

}