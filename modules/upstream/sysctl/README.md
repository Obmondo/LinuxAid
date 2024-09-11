# puppet-sysctl

## Apache 2 notice
This code contains work produced by Matthias Saou with revisions made by
Thomas Downes in accordance with the Apache 2.0 license under which it
was released. It is re-released under Apache 2.0.

The modifications restructure the code

 * to allow the code to work at all in Puppet 4
 * to take advantage of features only available in Puppet 4
 * to address several issues in the original code that stem from the existence
   of a `sysctl::base` class while `sysctl` itself was a defined resource. The
   solution chosen was to make `sysctl` a class that uses a new defined resource
   `sysctl::configuration`. It is therefore intentionally not backwards-compatible
   but the changes are minor and documented below.

## Overview

Manage sysctl variable values. All changes are immediately applied, configured
to be persistent upon reboots, and optionally enforced on every Puppet run to
if changes are made outside of this module. Tested on RHEL 6/7 derivatives and
Debian 7/8.

 * `sysctl`: base class that should be included in catalog
 * `sysctl::configuration`: defined resource that manages specific key/values.

For persistence to work, your OS needs to support looking for sysctl configuration
inside `/etc/sysctl.d/`.

You may optionally enable purging of the `/etc/sysctl.d/` directory, so that
all files which are not (or no longer) managed by this module will be removed.

You may also force a value to `ensure => absent`, which will revert a key to its
default value upon the next reboot.

If settings for a key exist within `/etc/sysctl.conf`, they are removed using `sed`.

## Examples

Enable IP forwarding globally:
```puppet
sysctl::configuration { 'net.ipv4.ip_forward':
  value => '1'
}
```
or using hiera with `hiera_include(classes)`:

```yaml
classes:
  - sysctl

sysctl::values:
  net.ipv4.ip_forward:
    value: '1'
```

Multi-valued settings should be set with a single space between them so
that the enforcement on each run can be successful.
```yaml
sysctl::values:
  net.ipv4.tcp_rmem:
    value: '4096 65536 16777216'
```

Values can be unset so that they return to default at next reboot
```puppet
sysctl::configuration { 'vm.swappiness':
  ensure => absent
}
```

You can enforce the order in which the variables are set by using a prefix:
```puppet
sysctl::configuration { 'net.ipv4.ip_forward':
  value => '1',
  prefix => '60'
}
```

To enable purging of settings not known to this module, you can set
`sysctl::purge` to true (default: false)
