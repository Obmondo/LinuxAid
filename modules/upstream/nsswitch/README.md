# nsswitch.conf module for Puppet

[![License](https://img.shields.io/github/license/voxpupuli/puppet-nsswitch.svg)](https://github.com/voxpupuli/puppet-nsswitch/blob/master/LICENSE)
[![CI Status](https://github.com/voxpupuli/puppet-nsswitch/workflows/CI/badge.svg?branch=master)]((https://github.com/voxpupuli/puppet-nsswitch/workflows/CI/badge.svg?branch=master))
[![Puppet Forge](https://img.shields.io/puppetforge/v/puppet/nsswitch.svg)](https://forge.puppetlabs.com/puppet/nsswitch)
[![Puppet Forge - downloads](https://img.shields.io/puppetforge/dt/puppet/nsswitch.svg)](https://forge.puppetlabs.com/puppet/nsswitch)
[![Puppet Forge - endorsement](https://img.shields.io/puppetforge/e/puppet/nsswitch.svg)](https://forge.puppetlabs.com/puppet/nsswitch)
[![Puppet Forge - scores](https://img.shields.io/puppetforge/f/puppet/nsswitch.svg)](https://forge.puppetlabs.com/puppet/nsswitch)

A way of expressing nsswitch.conf configurations declaratively.

### Defaults

Currently this module has support for EL based Linux distributions,
Fedora, Debian/Ubuntu, and Gentoo. This module by default will create a basic
nsswitch.conf that uses defaults derived from what the distribution uses in
the nsswitch.conf file on fresh install. These defaults have been verified
on the mentioned distributions by the kindness and diligence of
contributors, of which I'm very grateful.

### Usage

See [REFERENCE.md](./REFERENCE.md) for full API details.

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

## Authors and Module History

Puppet-nsswitch has been maintained by VoxPupuli since version 3.0.0.
It was migrated from https://forge.puppet.com/modules/trlinkin/nsswitch.
It is licensed under the Apache-2 license.