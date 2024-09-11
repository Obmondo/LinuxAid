#
# Uses wildfly_resource to ensure configuration state
#
define wildfly::util::resource($ensure = 'present', $content = undef, $recursive = false, $profile = undef) {

  $profile_path = profile_path($profile)
  $users_mgmt = keys($::wildfly::users_mgmt)
  $passwords_mgmt = values($::wildfly::users_mgmt)

  wildfly_resource { "${profile_path}${name}":
    ensure    => $ensure,
    username  => $users_mgmt[0],
    password  => $passwords_mgmt[0]['password'],
    host      => $::wildfly::mgmt_bind,
    port      => $::wildfly::mgmt_http_port,
    recursive => $recursive,
    state     => delete_undef_values($content),
  }

}
