# Common Monitoring
class common::monitoring (
  Boolean $manage = true,
) {

  if $manage {
    if lookup('common::monitoring::splunk::forwarder::enable', Boolean, undef, false) {
      include common::monitoring::splunk::forwarder
    }

    if lookup('common::monitoring::scom::enable', Boolean, undef, false) {
      include common::monitoring::scom
    }

    include common::monitoring::atop
  }
}
