# Define: dmcrypt::open
#
# Open a dmcrypt device created before
#
# Set the $host_secret parameter if you want to use only
# one secret/key per host for all the later setup devices in
# this node.
#
# == Name
#   Unused
# == Parameters
# [*device*] The device to open as LUKS device
#   Mandatory.
#
# [*name*] The mapping name.
#   Mandatory.
#
# [*host_secret*] If one secret/key per host should be used
#   Optional. Defaults to 'false'
#
# == Dependencies
#
# Packages: cryptsetup
#
# == Authors
#
#  Jan Alexander Slabiak <j.slabiak@telekom.de>
#  Danny Al-Gaaf <d.al-gaaf@telekom.de>
#
# == Copyright
#
# Copyright 2013 Deutsche Telekom AG
#

define dmcrypt::open(
  $device,
  $key_path  = '/root',
  $luks_name = undef,
) {
  $secret_name = basename($device)

  if !($luks_name) {
    $_luks_name = "luks_${secret_name}"
  } else {
    $_luks_name = $luks_name
  }

  exec {"luksOpen-${secret_name}":
    path    => "/usr/sbin:/usr/bin:/sbin:/bin:",
    command => "cryptsetup luksOpen ${device} ${_luks_name} -d ${key_path}/${secret_name}.key",
    creates => "/dev/mapper/${_luks_name}",
    require => Package['cryptsetup']
  }
}
