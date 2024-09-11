puppet-dmcrypt
==============

puppet module to use dmcrypt/LUKS

About
=====

Decrypt and use LUKS encrypted device.

This module allows to decrypt and mount a LUKS encrypted device. If the device has not been formatted before, it is formatted with XFS. "not formatted before" means that the first 10 MB of the device are filled with zeroes.

The module also allows to format a device with a random key and use it for nova instance files. This volume is lost upon power down / reboot which is the purpose of the module.

Usage
=====

    class {'dmcrypt': }

    dmcrypt::luksDevice {'/dev/vdb1':
      name        => 'osd-1',
      mount_point => '/var/lib/ceph/osd/ceph-1'
    }

... and probably more calls to `dmcrypt::luksDevice`

To format /dev/sdb2 to be used as a self-destructing nova-instance storage do this:

    dmcryt::ephemeral_nova {'/dev/sdb2': }

Compatibility
=============

Works at least on Ubuntu 12.04 with puppet 2.7.11 and cryptsetup 1.4.1.

ToDo
=====
 - Testing
 - Update of documentation
