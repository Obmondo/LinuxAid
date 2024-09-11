# BeegFS
class role::storage::beegfs (
  Boolean                     $enable,
  Eit_types::Host             $mgmtd_host        = 'localhost',
  Array[Stdlib::Absolutepath] $storage_directory = '/local/beegfs',
  Boolean                     $client            = true,
  Boolean                     $mgmtd             = false,
  Boolean                     $storage           = true,
  Boolean                     $meta              = true,
  Boolean                     $admon             = false,
  Stdlib::Port                $admon_http_port   = 8000,
  Stdlib::Port                $storage_port      = 8003,
  Stdlib::Port                $client_udp_port   = 8004,
  Stdlib::Port                $meta_port         = 8005,
  Stdlib::Port                $helperd_tcp_port  = 8006,
  Stdlib::Port                $admon_udp_port    = 8007,
  Stdlib::Port                $mgmtd_port        = 8008,
  Array[String]               $interfaces        = [],
  Boolean                     $__blendable,
) {

  confine($enable,
          $::common::system::selinux::enable,
          'selinux must be disabled')

  contain 'profile::storage::beegfs'

}
