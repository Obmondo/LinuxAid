# @summary Class for managing the NIS/ypclass common::system::authentication::nis
#
# @param domain The domain for NIS. Can be a simple string or a host. Defaults to 'nis'.
#
# @param servers An array of IP addresses of NIS servers. Defaults to an empty array.
#
# @param enable Boolean to enable NIS authentication. Defaults to false.
#
class common::system::authentication::nis (
  Variant[Eit_types::SimpleString, Stdlib::Host] $domain  = 'nis',
  Array[Stdlib::IP::Address]                     $servers = [],
  Boolean                                        $enable  = false,
) inherits ::common::system::authentication {

  confine($enable, $servers.size == 0,
          '`$servers` must contain at least one entry')

  contain profile::system::authentication::nis
}
