# Repo Mirror
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
