class drbd::service {
  @service { 'drbd':
    ensure  => running,
    enable  => $drbd::service_enable,
    require => Package['drbd'],
    restart => 'service drbd reload',
  }
}
