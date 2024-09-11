define wildfly::util::reload($retries = 3, $wait = 10) {

  $users_mgmt = keys($::wildfly::users_mgmt)
  $passwords_mgmt = values($::wildfly::users_mgmt)

  wildfly_reload { $name:
    username => $users_mgmt[0],
    password => $passwords_mgmt[0]['password'],
    host     => $::wildfly::mgmt_bind,
    port     => $::wildfly::mgmt_http_port,
    retries  => $retries,
    wait     => $wait,
  }

}
