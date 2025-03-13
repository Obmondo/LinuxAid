# @summary BeegFS class for managing storage
#
# @param enable Flag to enable or disable the BeegFS role.
#
# @param mgmtd_host The host for the management daemon. Defaults to 'localhost'.
#
# @param storage_directory The directory for BeegFS storage. Defaults to '/local/beegfs'.
#
# @param client Flag to indicate if the client should be installed. Defaults to true.
#
# @param mgmtd Flag to indicate if the management daemon should be installed. Defaults to false.
#
# @param storage Flag to indicate if the storage service should be enabled. Defaults to true.
#
# @param meta Flag to indicate if the metadata service should be enabled. Defaults to true.
#
# @param admon Flag to indicate if the administration service should be enabled. Defaults to false.
#
# @param admon_http_port The HTTP port for the administration service. Defaults to 8000.
#
# @param storage_port The port for the storage service. Defaults to 8003.
#
# @param client_udp_port The UDP port for the client. Defaults to 8004.
#
# @param meta_port The port for the metadata service. Defaults to 8005.
#
# @param helperd_tcp_port The TCP port for the helper daemon. Defaults to 8006.
#
# @param admon_udp_port The UDP port for the administration service. Defaults to 8007.
#
# @param mgmtd_port The port for the management daemon. Defaults to 8008.
#
# @param interfaces An array of network interfaces to bind to. Defaults to an empty array.
#
# @param $__blendable
# A flag for blendable functionality.
#
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
