# @summary Manages beegfs installations
#
# @param manage_repo
# @param mgmtd_host
# @param meta_directory
# @param storage_directory
# @param client_auto_remove_mins
# @param meta_space_low_limit
# @param meta_space_emergency_limit
# @param storage_space_low_limit
# @param storage_space_emergency_limit
# @param package_source
# @param version
# @param log_dir
# @param log_type
# @param log_level
# @param user
# @param group
# @param release
# @param dist
# @param admon_db_file
# @param enable_quota
# @param enable_acl
# @param allow_user_set_pattern
# @param enable_rdma
# @param conn_auth_file
# @param allow_new_servers
# @param allow_new_targets
# @param admon_http_port
# @param storage_tcp_port
# @param storage_udp_port
# @param client_udp_port
# @param meta_tcp_port
# @param meta_udp_port
# @param helperd_tcp_port
# @param admon_udp_port
# @param mgmtd_tcp_port
# @param mgmtd_udp_port
#
class beegfs (
  Boolean                        $manage_repo                   = true,
  Stdlib::Host                   $mgmtd_host                    = 'localhost',
  Stdlib::AbsolutePath           $meta_directory                = '/srv/beegfs/meta',
  Array[Stdlib::AbsolutePath]    $storage_directory             = ['/srv/beegfs/storage',],
  Integer[0,default]             $client_auto_remove_mins       = 30,
  Beegfs::ByteAmount             $meta_space_low_limit          = '10G',
  Beegfs::ByteAmount             $meta_space_emergency_limit    = '3G',
  Beegfs::ByteAmount             $storage_space_low_limit       = '100G',
  Beegfs::ByteAmount             $storage_space_emergency_limit = '20G',
  Beegfs::PackageSource          $package_source                = 'beegfs',
  Optional[String]               $version                       = undef,
  Beegfs::LogDir                 $log_dir                       = '/var/log/beegfs',
  Beegfs::LogType                $log_type                      = 'logfile',
  Beegfs::LogLevel               $log_level                     = 3,
  String                         $user                          = 'root',
  String                         $group                         = 'root',
  Beegfs::Release                $release                       = '7.4.0',
  Optional[String]               $dist                          = undef,
  Stdlib::AbsolutePath           $admon_db_file                 = '/var/lib/beegfs/beegfs-admon.db',
  Boolean                        $enable_quota                  = false,
  Boolean                        $enable_acl                    = false,
  Boolean                        $allow_user_set_pattern        = false,
  Boolean                        $enable_rdma                   = true,
  Optional[Stdlib::AbsolutePath] $conn_auth_file                = undef,
  Boolean                        $allow_new_servers             = false,
  Boolean                        $allow_new_targets             = false,
  Stdlib::Port                   $admon_http_port               = 8000,
  Stdlib::Port                   $storage_tcp_port              = 8003,
  Stdlib::Port                   $storage_udp_port              = 8003,
  Stdlib::Port                   $client_udp_port               = 8004,
  Stdlib::Port                   $meta_tcp_port                 = 8005,
  Stdlib::Port                   $meta_udp_port                 = 8005,
  Stdlib::Port                   $helperd_tcp_port              = 8006,
  Stdlib::Port                   $admon_udp_port                = 8007,
  Stdlib::Port                   $mgmtd_tcp_port                = 8008,
  Stdlib::Port                   $mgmtd_udp_port                = 8008,
) inherits beegfs::params {
  $package_ensure = pick($version, 'present')

  # release variable needs to be propagated in case common `beegfs::release`
  # is overriden
  class { 'beegfs::install':
    release => $release,
    dist    => $dist,
    user    => $user,
    group   => $group,
    log_dir => $log_dir,
  }
}
