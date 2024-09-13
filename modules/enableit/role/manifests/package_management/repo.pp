# Repo Mirror
class role::package_management::repo (
  Eit_types::User                  $user,
  Boolean                          $packagesign      = true,
  Stdlib::Unixpath                 $basedir,
  Stdlib::Fqdn                     $domain,
  Boolean                          $ssl,
  Optional[String]                 $ssl_cert,
  Optional[String]                 $ssl_key,
  String                           $registry_path,
  String                           $nginx_tag,
  Optional[String]                 $packagesign_tag  = undef,
  Optional[String]                 $signing_password = undef,
  Optional[Stdlib::HTTPSUrl]       $gitserver_url    = undef,
  Optional[String]                 $gitserver_token  = undef,
  Optional[Array]                  $volumes          = undef,
  Eit_types::SystemdTimer::Weekday $weekday,
  Boolean                          $manage           = true,
  Optional[Timestamp]              $snapshot         = undef,
  Enum['gitea', 'gitlab']          $provider         = 'gitlab',
  Hash                             $locations        = {},

  Repository::Mirrors::Configurations $configurations = {},
) inherits role::package_management {

  contain role::virtualization::docker
  contain role::web::haproxy

  include profile::package_management::repo

  if $packagesign {
    confine((!$packagesign_tag or !$nginx_tag or !$registry_path or !$volumes or !$signing_password or !$gitserver_url), 'Missing dependencies to enable packagesign: one or more variables are undef')

    include profile::package_management::packagesign
  }
}
