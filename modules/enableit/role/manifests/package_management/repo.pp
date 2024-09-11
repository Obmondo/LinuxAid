# Repo Mirror
class role::package_management::repo (
  Eit_types::User     $user,
  Stdlib::Unixpath    $basedir,
  Stdlib::Fqdn        $domain,
  String              $signing_password,
  Stdlib::HTTPSUrl    $gitserver_url,
  String              $gitserver_token,
  Boolean             $ssl,
  Optional[String]    $ssl_cert,
  Optional[String]    $ssl_key,
  Array               $volumes,
  String              $registry_path,
  String              $packagesign_tag,
  String              $nginx_tag,

  Eit_types::SystemdTimer::Weekday $weekday,

  Boolean             $manage   = true,
  Optional[Timestamp] $snapshot = undef,
  Enum[
    'gitea',
    'gitlab'
  ]                   $provider = 'gitlab',
  Hash                $locations = {},

  Repository::Mirrors::Configurations $configurations = {},
) inherits role::package_management {

  contain role::virtualization::docker
  contain role::web::haproxy

  include profile::package_management::repo
  include profile::package_management::packagesign
}
