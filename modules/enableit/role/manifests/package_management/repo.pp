
# @summary Class for managing the package management repo
#
# @param user The user to run the operations as.
#
# @param basedir The base directory for the repository management.
#
# @param ssl Whether to use SSL for connections. Defaults to false.
#
# @param ssl_cert The SSL certificate to use, if SSL is enabled. Defaults to undef.
#
# @param ssl_key The SSL key to use, if SSL is enabled. Defaults to undef.
#
# @param registry_path The path to the registry.
#
# @param packagesign Whether to enable package signing. Defaults to false.
#
# @param volumes The volumes to use. Defaults to undef.
#
# @param manage Whether to manage the repository. Defaults to true.
#
# @param locations A hash of locations for the repository.
#
# @param snapshot Whether to create a snapshot of the repository. Defaults to false.
#
# @param signing_password The password for signing, if package signing is enabled. Defaults to undef.
#
# @param snapshot_tag The tag to use for snapshotting.
#
# @param nginx_path The path for Nginx configurations.
#
# @param nginx_tag The tag for Nginx configurations.
#
# @param script_tag The script tag for additional operations, if needed. Defaults to undef.
#
# @param configurations The repository mirror configurations to use.
#
# @param weekday The weekday for the systemd timer for the repository operations.
#
# @param server_tag An optional server tag for additional configurations. Defaults to undef.
#
# @param gitserver_url The URL of the Git server, if used. Defaults to undef.
#
# @param gitserver_token The token for accessing the Git server, if used. Defaults to undef.
#
# @param provider The provider for the repository, defaults to undef.
#
# @param encrypt_params The list of params, which needs to be encrypted
#
# @groups ssl ssl, ssl_cert, ssl_key
#
# @groups signing packagesign, signing_password, script_tag
#
# @groups snapshot snapshot, snapshot_tag
#
# @groups nginx nginx_path, nginx_tag
#
# @groups git gitserver_url, gitserver_token
#
# @groups misc user, basedir, registry_path, volumes, manage, locations, configurations, weekday, server_tag, provider, encrypt_params
#
# @encrypt_params signing_password, gitserver_token
#
class role::package_management::repo (
  Eit_types::User  $user,
  Stdlib::Unixpath $basedir,
  Boolean          $ssl,
  Optional[String] $ssl_cert,
  Optional[String] $ssl_key,
  String           $registry_path,
  Boolean          $packagesign,
  Optional[Array]  $volumes,
  Boolean          $manage,
  Hash             $locations,
  Boolean          $snapshot,
  Optional[String] $signing_password,
  String           $snapshot_tag,
  String           $nginx_path,
  String           $nginx_tag,
  Optional[String] $script_tag,
  Repository::Mirrors::Configurations $configurations,
  Eit_types::SystemdTimer::Weekday    $weekday,
  Optional[String]           $server_tag,
  Optional[Stdlib::HTTPSUrl] $gitserver_url,
  Optional[String]           $gitserver_token,
  Optional[Enum['gitlab']]   $provider,

  Eit_types::Encrypt::Params $encrypt_params       = [
    'signing_password',
    'gitserver_token',
  ]

) inherits role::package_management {

  confine($server_tag, !($gitserver_url and $gitserver_token),
    'Enabling packagesign-server requires **gitserver_url** and **gitserver_token** and **server_tag** to be set')
  confine($packagesign, !($script_tag and $signing_password),
    'Enabling packagesign-script requires **script_tag** and **signing_password** to be set')

  contain role::virtualization::docker
  contain role::web::haproxy
  include profile::package_management::repo
  include profile::package_management::packagesign
}
