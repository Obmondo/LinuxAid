
##
# This is a helper function
#
# Performs a 'cryptsetup luksFormat' for the given device iff the device is
# empty, which is defined as "the first 10 MB contain only zeroes".
#
# Parameter:
#  $title    = device to format
#  $key_file = file containing the key to use
#
# Postcondition:
#  the device is a formatted LUKS device
define dmcrypt::luksFormat($key_file) {
  $device = $title

  exec {"luksFormat-${device}":
    path    => '/bin:/usr/bin:/usr/sbin:/sbin',
    command => "cryptsetup -q \
                --cipher aes-xts-plain64 \
                --key-size 512 \
                --hash sha512 \
                --use-urandom \
                --key-file ${key_file} \
                luksFormat ${device}",
    onlyif  => "test f1c9645dbc14efddc7d8a322685f26eb = \
                $(dd if=${device} bs=1k count=10k 2>/dev/null \
                | md5sum - | cut -f1 -d' ')",
    require => Package['cryptsetup']
  }
}

##
# This is a helper function
#
# performs a 'cryptsetup luksOpen' for the given device
#
# Parameter:
#  $title    = device to decrypt
#  $name     = name to assign to the decrypted device
#  $key_file = file containing the key to use
#
# Postcondition:
#  The device is decrypted and available as the given name
define dmcrypt::luksOpen($key_file) {
  $device = $title

  exec {"luksOpen-${device}":
    command => "/sbin/cryptsetup luksOpen ${device} ${name} -d ${key_file}",
    creates => "/dev/mapper/${name}",
    require => Package['cryptsetup']
  }
}

##
# Decrypts and mounts the given device at the given mount point
#
# If the device is empty (i.e. first 10 MB are zeroed) then it is formatted
# with both luksFormat and mkfs.xfs.
#
# Parameter:
#  $title       = device to use
#  $name        = name to assign to the decrypted device
#  $key_file    = file containing the key to use
#  $mount_point = where to mount the device
#
# Postcondition:
#  The given device is decrypted and available a the given mountpoint
define dmcrypt::luksDevice($mount_point) {
  $device = $title

  $secret_path = "puppet:///secrets/$name"
  $key_file = "/root/${name}.key"

  file {$key_file:
    ensure  => present,
    mode    => '0600',
    source  => $secret_path,
  }
  -> dmcrypt::luksFormat {$device:
    key_file => $key_file,
    notify   => Exec["format-${device}"]
  }
  -> dmcrypt::luksOpen {$device:
    name     => $name,
    key_file => $key_file,
  }
  ~> mount {$mount_point:
    ensure    => mounted,
    atboot    => false,
    device    => "LABEL=${name}",
    fstype    => 'auto',
    options   => 'noauto',
    subscribe => Exec["format-${device}"]
  }

  exec {"format-${device}":
    command     => "mkfs.xfs -L ${name} -i size=2048 /dev/mapper/${name}",
    path        => '/bin:/usr/bin:/usr/sbin:/sbin',
    require     => [Package['xfsprogs'], Exec["luksOpen-${device}"]],
    refreshonly => true
  }
}

##
# Encrypts a device with a random key, formats it and mounts it at
# /var/lib/nova/instances/ so that it is used for the nova instances
#
# Parameters:
#   $title = device to used
#
# Usage:
#
# dmcryt::ephemeral_nova {'/dev/sdb2': }
#
define dmcrypt::ephemeral_nova() {
  $device = $title

  file {'/etc/crypttab':
    ensure  => present,
    mode    => '0600',
    content => "nova $device /dev/urandom cipher=aes-xts-plain64,size=256,hash=sha512"
  }

  package {'cryptsetup':
    ensure => installed
  }

  mount {'/var/lib/nova/instances':
    ensure  => present,
    atboot  => false,
    device  => '/dev/mapper/nova',
    fstype  => 'auto',
    options => 'noauto'
  }

  file {'/etc/init/mount-nova.conf':
    ensure  => present,
    mode    => '0644',
    source  => 'puppet:///modules/dtagcloud/nova/mount-nova.conf',
    require => [File['/etc/crypttab'],
                Package['cryptsetup'],
                Mount['/var/lib/nova/instances']],
  }

  exec {'/usr/sbin/service mount-nova start':
    require   => File['/etc/init/mount-nova.conf'],
    subscribe => File['/etc/init/mount-nova.conf'],
    creates   => '/var/lib/nova/instances/lost+found'
  }
}
