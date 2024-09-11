# =Class perforce
#
# ==Description
# install and configure perforce
#
class perforce (
  String                         $user,
  String                         $group,
  String                         $service_name,
  String                         $service_password,
  Stdlib::Port                   $service_port,
  Stdlib::AbsolutePath           $service_root,
  Stdlib::AbsolutePath           $install_root,
  Stdlib::AbsolutePath           $var_dir,
  Optional[Stdlib::HTTPSUrl]     $rpm_gpg_key_url,
  Optional[String]               $license_content,
  Optional[Stdlib::AbsolutePath] $service_ssldir,
  Stdlib::AbsolutePath           $service_log_dir = '/var/log/perforce',
  Perforce::LogFile              $service_log = 'stderr',
  Perforce::LogLevel             $service_log_level = 1,
  Perforce::Version              $version,
  Array[String]                  $packages,
  Perforce::Host                 $server_name = $facts['hostname'],
){

  contain perforce::repository
  contain perforce::install
  contain perforce::license
  contain perforce::configure
  contain perforce::service
}
