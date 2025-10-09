# 
# Create a virtual service resource
# to be realized upon needed
#
# @summary drbd service
#
class drbd::service {
  if $drbd::service_ensure == 'unmanaged' {
    $_ensure = undef
  } else {
    $_ensure = $drbd::service_ensure
  }

  @service { 'drbd':
    ensure  => $_ensure,
    enable  => $drbd::service_enable,
    require => Package['drbd'],
    restart => 'service drbd reload',
  }
}
