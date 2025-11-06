# =Class perforce
#
# ==Description
# install and configure perforce
#
class perforce (
  String                         $user,
  String                         $service_name,
  String                         $service_password,
  Stdlib::Port                   $service_port,
  Stdlib::AbsolutePath           $service_root,
  Stdlib::AbsolutePath           $install_root,
  Optional[Stdlib::HTTPSUrl]     $rpm_gpg_key_url,
  Optional[String]               $license_content,
  Optional[Stdlib::AbsolutePath] $service_ssldir,
  Perforce::Version              $version,
  Array[String]                  $packages,
){

  contain perforce::repository
  contain perforce::package
  contain perforce::install
  contain perforce::configure
  contain perforce::service
  contain perforce::license

  Class['::perforce::repository']
  -> Class['::perforce::package']
  -> Class['::perforce::install']
  -> Class['::perforce::license']
  -> Class['::perforce::configure']
  ~> Class['::perforce::service']
}
