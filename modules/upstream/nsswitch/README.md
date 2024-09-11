# nsswitch.conf module for Puppet
[![Build Status](https://travis-ci.org/trlinkin/puppet-nsswitch.svg?branch=master)](https://travis-ci.org/trlinkin/puppet-nsswitch)

A way of expressing nsswitch.conf configurations declaratively. This
should manage the standard 15 databases NSS supports, plus the `sudo` entry
respected by sudo since the 1.7.0 release.

### Updated for Puppet 4 - No Puppet 3 Compatibility

The 2.x series of this module officially adopts the Puppet 4 parser syntax and
other new Puppet features. The 2.x series will no longer work with Puppet 3 or
earlier. One benefit is the removal of dependency the `trlinkin-validate_multi`
module.

### Defaults

Currently this module has support for EL based Linux distributions,
Fedora, Debian/Ubuntu, and Gentoo. This module by default will create a basic
nsswitch.conf that uses defaults derived from what the distribution uses in
the nsswitch.conf file on fresh install. These defaults have been verified
on the mentioned distributions by the kindness and diligence of
contributors, of which I'm very grateful.

### Supported Systems

This module should be capable of supporting the following systems using
Puppet versions 4 and 5 with the ruby versions that are released with
the AIO (all in one installer). For an exact matrix see `.travis.yml`.

 * Debian/Ubuntu 10.04, 12.04
 * Solaris 10, 11, 11.1, 11.2, 11.3
 * Variants of Enterprise Linux 6 and 7 (Such as Amazon Linux, Scientific Linux, etc)
 * Fedora (defaults need validation)
 * Gentoo
 * FreeBSD 10.3, 10.4, 11.1
 * LinuxMint 17.2
 * SLES 11, 12

Testing has only confirmed functionality on the following:
  * Ubuntu 12.4
  * Fedora 19
  * Centos 6/7
  * RHEL 6/7

### Usage

#### nsswitch class

This is the class by which you will manage the nsswitch.conf file. There
is one parameter per standard database NSS supports. The class accepts both strings
and arrays as parameters. The benefit being, you could possibly merge an array
of options with hiera. When using an array, each element should be the
lookup service followed by the reaction statement.

Available parameters are:

* passwd
* group
* shadow
* hosts
* bootparams
* aliases
* automount
* ethers
* netgroup
* netmasks
* network
* protocols
* publickey
* rpc
* services
* shells
* sudo


For more information on NSS, please see the man pages. `man 5 nsswitch.conf`

#### Examples

```puppet
# defaults only
include nsswitch

# setting a simple lookup
class { 'nsswitch':
  publickey => 'nis',
}

# 'hosts' lookups contain a reaction statement for the 'dns' service
class { 'nsswitch':
  passwd => ['ldap','files'],
  hosts  => ['dns [!UNAVAIL=return]','files'],
}
```

#### Example nsswitch.conf with all defaults for RHEL systems

    # This file is controlled by Puppet

    passwd:     files
    shadow:     files
    group:      files
    hosts:      files dns
    bootparams: nisplus [NOTFOUND=return] files
    ethers:     files
    netmasks:   files
    networks:   files
    protocols:  files
    rpc:        files
    services:   files
    netgroup:   nisplus
    publickey:  nisplus
    automount:  files nisplus
    aliases:    files nisplus
