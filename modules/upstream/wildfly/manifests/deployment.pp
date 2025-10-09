#
# Manages a deployment (JAR, EAR, WAR) in Wildfly.
#   This define is a wrapper for `wildfly_deployment` that defaults to your local Wildfly installation.
#
# @param ensure Whether the deployment should exist (`present`) or not (`absent`).
# @param source Sets the source for this deployment, either a local file `file://` or a remote file `http://`.
# @param timeout Sets the timeout to deploy this resource.
# @param server_group Sets the target `server-group` for this deployment.
# @param operation_headers Sets [operation-headers](https://docs.jboss.org/author/display/WFLY9/Admin+Guide#AdminGuide-OperationHeaders) (e.g. `{ 'allow-resource-service-restart' => true, 'rollback-on-runtime-failure' => false, 'blocking-timeout' => 600}`) to be used when creating/destroying this deployment.
define wildfly::deployment(
  Variant[Pattern[/^file:\/\//], Pattern[/^puppet:\/\//], Stdlib::Httpsurl, Stdlib::Httpurl] $source,
  Enum[present, absent] $ensure = present,
  Optional[Integer] $timeout     = undef,
  Optional[String] $server_group = undef,
  $operation_headers             = {}) {

  $file_name = inline_template('<%= File.basename(URI::parse(@source).path) %>')

  file { "/opt/${file_name}":
    ensure => 'present',
    owner  => $wildfly::user,
    group  => $wildfly::group,
    mode   => '0655',
    source => $source
  }

  wildfly_deployment { $title:
    ensure            => $ensure,
    server_group      => $server_group,
    username          => $wildfly::mgmt_user['username'],
    password          => $wildfly::mgmt_user['password'],
    host              => $wildfly::setup::properties['jboss.bind.address.management'],
    port              => $wildfly::setup::properties['jboss.management.http.port'],
    timeout           => $timeout,
    source            => "/opt/${file_name}",
    operation_headers => $operation_headers,
    require           => [Service['wildfly'], File["/opt/${file_name}"]],
  }

}
