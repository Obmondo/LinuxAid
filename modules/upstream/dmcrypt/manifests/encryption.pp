# Define: dmcrypt::encryption
#
# To encrypt a given device with LUKS/dmcrypt.
#
# If you plan to use only one secret/key per host for cryptsetup,
# you need to setup the key via dmcrypt::core and pass 'true' for
# $host_secret to this define.
#
# Generate a key file to be used with dmcrypt
#
# == Name
#   Unused
# == Parameters
# [*device*] The name of the device that should get encrypted.
#   This is the device name without the path (e.g. sdb or sdd).
#   Mandatory.
#
# [*host_secret*] If one secret/key per host should be used
#   Optional. Defaults to 'false'
#
# [*secret*] A secret to be used in the key.
#   Optional.
#
# == Dependencies
#
# cryptsetup
#
# == Authors
#
#  Jan Alexander Slabiak <j.slabiak@telekom
#  Danny Al-Gaaf <d.al-gaaf@telekom.de>
#
# == Copyright
#
# Copyright 2013 Deutsche Telekom AG

define dmcrypt::encryption (
  $device,
  $host_secret = false,
  $secret      = undef,
  $key_path    = '/root',
) {
  # resources
  if $host_secret == true {
    # in this case already defined!
    $secret_name = "dmcrypt-${::hostname}"
  } else {
    $secret_name = basename($device)

    dmcrypt::key { "${secret_name}":
      key_name      => $secret_name,
      key_path      => $key_path,
      custom_secret => $secret,
    }
  }

  $key_file = "${key_path}/${secret_name}.key"

  exec {"luksFormat-${secret_name}":
    path    => '/bin:/usr/bin:/usr/sbin:/sbin',
    command => "cryptsetup -q \
                --cipher aes-xts-plain64 \
                --key-size 512 \
                --hash sha512 \
                --use-urandom \
                --key-file ${key_file} \
                luksFormat ${device}",
    unless  => "cryptsetup isLuks ${device}",
    require => [ Package['cryptsetup'], File["${key_file}"] ]
  }
}
