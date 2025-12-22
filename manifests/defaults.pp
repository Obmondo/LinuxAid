include stdlib

if $facts['service_provider'] == 'systemd' {
  exec { 'daemon-reload':
    path        => ['/bin','/sbin'],
    command     => 'systemctl daemon-reload',
    refreshonly => true,
  }
}
