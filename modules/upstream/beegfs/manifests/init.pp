# Class: beegfs
# ===========================
#
#
# Parameters
# ----------
#
# * `mgmtd_host`
#   ipaddress of management node
#
class beegfs (
  Boolean                     $manage_repo                   = true,
  Stdlib::Host                $mgmtd_host                    = 'localhost',
  Stdlib::AbsolutePath        $meta_directory                = '/srv/beegfs/meta',
  Array[Stdlib::AbsolutePath] $storage_directory             = ['/srv/beegfs/storage',],
  Integer[0,default]          $client_auto_remove_mins       = 30,
  Beegfs::ByteAmount          $meta_space_low_limit          = '10G',
  Beegfs::ByteAmount          $meta_space_emergency_limit    = '3G',
  Beegfs::ByteAmount          $storage_space_low_limit       = '100G',
  Beegfs::ByteAmount          $storage_space_emergency_limit = '20G',
  Beegfs::PackageSource       $package_source                = 'beegfs',
                              $version                       = undef,
  Beegfs::LogDir              $log_dir                       = '/var/log/beegfs',
  Beegfs::LogType             $log_type                      = 'logfile',
  Beegfs::LogLevel            $log_level                     = 3,
  String                      $user                          = 'root',
  String                      $group                         = 'root',
  Beegfs::Release             $release                       = '2015.03',
  Stdlib::AbsolutePath        $admon_db_file                 = '/var/lib/beegfs/beegfs-admon.db',
  Boolean                     $enable_quota                  = false,
  Boolean                     $enable_acl                    = false,
  Boolean                     $allow_new_servers             = false,
  Boolean                     $allow_new_targets             = false,
  Stdlib::Port                $admon_http_port               = 8000,
  Stdlib::Port                $storage_tcp_port              = 8003,
  Stdlib::Port                $storage_udp_port              = 8003,
  Stdlib::Port                $client_udp_port               = 8004,
  Stdlib::Port                $meta_tcp_port                 = 8005,
  Stdlib::Port                $meta_udp_port                 = 8005,
  Stdlib::Port                $helperd_tcp_port              = 8006,
  Stdlib::Port                $admon_udp_port                = 8007,
  Stdlib::Port                $mgmtd_tcp_port                = 8008,
  Stdlib::Port                $mgmtd_udp_port                = 8008,
) inherits ::beegfs::params {

  $package_ensure = if $version == undef {
    'present'
  } else {
    $version
  }
}
