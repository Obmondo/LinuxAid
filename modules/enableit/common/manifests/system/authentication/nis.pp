# NIS/yp
class common::system::authentication::nis (
  Variant[Eit_types::SimpleString, Stdlib::Host] $domain  = 'nis',
  Array[Stdlib::IP::Address]                     $servers = [],
  Boolean                                        $enable  = false,
) inherits ::common::system::authentication {

  confine($enable, $servers.size == 0,
          '`$servers` must contain at least one entry')

  contain profile::system::authentication::nis
}
