# Make sure init_system is set
confine(!$facts['init_system'], 'Unable to determine init system, aborting')

include ::stdlib

Package { allow_virtual => true }

# Have renamed the exec resources from systemctl daemon-reload to daemon-reolad
# since it was getting clash with upstream module slurmd

if $facts['init_system'] == 'systemd' {
  exec { 'daemon-reload':
    path        => ['/bin','/sbin'],
    command     => 'systemctl daemon-reload',
    refreshonly => true,
  }
}
