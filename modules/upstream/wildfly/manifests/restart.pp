#
# Performs a full restart system when a restart is required `server-state=restart-required`.
#   This define is a wrapper for `wildfly_restart` that defaults to your local Wildfly installation.
#   It is commonly used as a subscriber of a resource that requires restart.
#
# @param retries Sets the number of retries to check if service is available.
# @param wait Sets the amount of time in seconds that this resource will wait for the service to be available before a attempt.
# @param username Wildfly's management user to be used internally.
# @param password The password for Wildfly's management user.
# @param host The IP address or FQDN of the JBoss Management service.
# @param port The port of the JBoss Management service.
# @param secure Use https port or http port.
#
define wildfly::restart (
  Integer $retries  = 3,
  Integer $wait     = 20,
  String  $username = $wildfly::mgmt_user['username'],
  String  $password = $wildfly::mgmt_user['password'],
  String  $host     = $wildfly::properties['jboss.bind.address.management'],
  String  $port     = $wildfly::properties['jboss.management.http.port'],
  Boolean $secure   = $wildfly::secure_mgmt_api,
) {
  if $secure {
    $_port = $wildfly::properties['jboss.management.https.port']
  }
  else {
    $_port = $port
  }

  wildfly_restart { $title:
    username => $username,
    password => $password,
    host     => $host,
    port     => $_port,
    secure   => $secure,
    retries  => $retries,
    wait     => $wait,
    require  => Service['wildfly'],
  }
}
