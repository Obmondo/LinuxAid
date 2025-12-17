#
# Manages a deployment (JAR, EAR, WAR) in Wildfly.
#   This define is a wrapper for `wildfly_deployment` that defaults to your local Wildfly installation.
#
# @param ensure Whether the deployment should exist (`present`) or not (`absent`).
# @param source Sets the source for this deployment, either a local file `file://` or a remote file `http://`.
# @param timeout Sets the timeout to deploy this resource.
# @param server_group Sets the target `server-group` for this deployment.
# @param operation_headers Sets [operation-headers](https://docs.jboss.org/author/display/WFLY9/Admin+Guide#AdminGuide-OperationHeaders) (e.g. `{ 'allow-resource-service-restart' => true, 'rollback-on-runtime-failure' => false, 'blocking-timeout' => 600}`) to be used when creating/destroying this deployment.
# @param username Wildfly's management user to be used internally.
# @param password The password for Wildfly's management user.
# @param host The IP address or FQDN of the JBoss Management service.
# @param port The port of the JBoss Management service.
# @param secure Use https port or http port.
#
define wildfly::deployment (
  Variant[
    Pattern[/^file:\/\//],
    Pattern[/^puppet:\/\//],
    Stdlib::Httpsurl,
    Stdlib::Httpurl
  ]                     $source,
  Enum[present, absent] $ensure            = present,
  Optional[Integer]     $timeout           = undef,
  Optional[String]      $server_group      = undef,
  Hash                  $operation_headers = {},
  String                $username          = $wildfly::mgmt_user['username'],
  String                $password          = $wildfly::mgmt_user['password'],
  String                $host              = $wildfly::properties['jboss.bind.address.management'],
  String                $port              = $wildfly::properties['jboss.management.http.port'],
  Boolean               $secure            = $wildfly::secure_mgmt_api,
) {
  $file_name = basename($source)

  file { "${wildfly::deploy_cache_dir}/${file_name}":
    ensure => 'file',
    owner  => $wildfly::user,
    group  => $wildfly::group,
    mode   => '0655',
    source => $source,
  }

  if $secure {
    $_port = $wildfly::properties['jboss.management.https.port']
  }
  else {
    $_port = $port
  }

  wildfly_deployment { $title:
    ensure            => $ensure,
    server_group      => $server_group,
    username          => $username,
    password          => $password,
    host              => $host,
    port              => $_port,
    secure            => $secure,
    timeout           => $timeout,
    source            => "${wildfly::deploy_cache_dir}/${file_name}",
    operation_headers => $operation_headers,
    require           => [Service['wildfly'], File["${wildfly::deploy_cache_dir}/${file_name}"]],
  }
}
