# Disable swap on the node as suggested at
# http://docs.datastax.com/en/landing_page/doc/landing_page/recommendedSettingsLinux.html
# @param device [string] If provided a mount resource will be created to
#   ensure that the device is absent from /etc/fstab to permanently disable swap.
# @param mount [string] The name of the swap mount point.  Ignored unless
#   `device` has been set.
# @param path [string] The full path to the file to check if swap is enabled.
# @see cassandra::params
class cassandra::system::swapoff (
  $device  = undef,
  $mount   = 'swap',
  $path    = '/proc/swaps',
) {
  exec { 'Disable Swap':
    command => 'swapoff --all',
    onlyif  => "grep -q '^/' ${path}",
    path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin'],
  }

  if $device {
    mount { $mount:
      ensure => absent,
      device => $device,
      fstype => 'swap',
    }
  }
}
