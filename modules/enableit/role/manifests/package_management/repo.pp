# Repo Mirror
class role::package_management::repo (
  Eit_types::User                  $user,
  Stdlib::Unixpath                 $basedir,
  Boolean                          $ssl,
  Optional[String]                 $ssl_cert,
  Optional[String]                 $ssl_key,
  String                           $registry_path,
  Eit_types::SystemdTimer::Weekday $weekday,
  Boolean                          $packagesign,
  Optional[String]                 $server_tag       = undef,
  Optional[String]                 $script_tag       = undef,
  Optional[Array]                  $volumes,
  Boolean                          $manage,
  Hash                             $locations,
  Boolean                          $snapshot,

  Repository::Mirrors::Configurations $configurations,
  String                           $snapshot_tag,
  String                           $nginx_path       = 'ghcr.io/obmondo/dockerfiles/repository-mirror',
  String                           $nginx_tag        = '1.27.0',
  Optional[String]                 $signing_password = undef,
  Optional[Stdlib::HTTPSUrl]       $gitserver_url    = undef,
  Optional[String]                 $gitserver_token  = undef,
  Optional[Enum['gitlab']]         $provider         = undef,

) inherits role::package_management {

  confine($packagesign, !($signing_password and $gitserver_url and $gitserver_token and $server_tag),
    'Enabling packagesigni-server requires **signing_password** and **gitserver_url** and **gitserver_token** and **server_tag** to be set')

  confine($packagesign, !($script_tag),
    'Enabling packagesign-script requires **script_tag** to be set')

  contain role::virtualization::docker
  contain role::web::haproxy

  include profile::package_management::repo
  include profile::package_management::packagesign
}
