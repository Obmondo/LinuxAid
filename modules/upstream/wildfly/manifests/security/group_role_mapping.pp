#
define wildfly::security::group_role_mapping($role, $group = $title, $realm = undef) {

  $_group = upcase($group)

  wildfly::util::resource { "/core-service=management/access=authorization/role-mapping=${role}/include=group-${_group}":
    content => {
      'name'  => $group,
      'realm' => $realm,
      'type'  => 'GROUP',
    },
  }

}